class Song < ActiveRecord::Base
  PURCHASE_TYPES    = %w(album song).freeze
  GROUPS_PER_PAGE   = 5
  REMOTE_ATTRIBUTES = %w(id title duration artwork_url permalink_url).freeze
  LOCAL_ATTRIBUTES  = %w(
    remote_id artist title duration artwork_url permalink_url
    purchase_type purchase_url
  ).freeze

  store_accessor :data, *LOCAL_ATTRIBUTES

  scope :published,              -> { where("published_on IS NOT NULL").desc(:published_on) }
  scope :published_before,       -> (date) { where("published_on < ?", date) }
  scope :published_on_or_before, -> (date) { where("published_on <= ?", date) }
  scope :unpublished,            -> { where("published_on IS NULL").asc(:id) }

  validates :data,          presence: true
  validates :remote_id,     presence: true, numericality: { only_integer: true }
  validates :artist,        presence: true
  validates :title,         presence: true
  validates :duration,      presence: true, numericality: { only_integer: true }
  validates :artwork_url,   presence: true
  validates :permalink_url, presence: true
  validates :purchase_type, inclusion: { in: PURCHASE_TYPES }, allow_blank: true

  def self.build_from_remote(id)
    return if id.blank?

    client = SoundCloud.new(client_id: ENV["SOUNDCLOUD_ID"])
    remote = client.get("/tracks/#{id}")

    return unless remote.streamable

    Song.new.tap do |song|
      song.update_from_remote(remote)
    end
  rescue SoundCloud::ResponseError
  end

  def self.paginate(options = {})
    limit = options[:per_page] || GROUPS_PER_PAGE
    dates = distinct.published.limit(options[:per_page]).pluck(:published_on)

    unscoped.where(published_on: dates).desc(:published_on)
  end

  def self.publish!(*ids)
    transaction do
      Song.where(id: ids).each(&:publish!)
    end
  end

  def artwork_url(style = nil)
    url = data["artwork_url"]

    if style.present?
      url.sub!(%r{-large.jpg\Z}, "-#{style}.jpg")
    end

    url
  end

  def publish!
    update!(published_on: Date.today)
  end

  def update_from_remote(remote)
    self.data = remote.with_indifferent_access.tap do |data|
      artist, title = data[:title].split(" - ", 2)

      data.slice!(*REMOTE_ATTRIBUTES)
      data[:title]     = title
      data[:artist]    = artist
      data[:duration]  = (data[:duration] / 1000.0).round
      data[:remote_id] = data.delete(:id)
    end
  end
end

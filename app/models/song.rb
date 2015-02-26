class Song < ActiveRecord::Base
  PURCHASE_TYPES    = %w(album song).freeze
  REMOTE_ATTRIBUTES = %w(id title duration artwork_url permalink_url).freeze
  LOCAL_ATTRIBUTES  = %w(
    remote_id artist title duration artwork_url permalink_url
    purchase_type purchase_url
  ).freeze

  scope :published,   -> { where("published_at IS NOT NULL").order("published_at DESC") }
  scope :unpublished, -> { where("published_at IS NULL").order("id ASC") }

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

  def self.publish!(*ids)
    transaction do
      Song.where(id: ids).each(&:publish!)
    end
  end

  LOCAL_ATTRIBUTES.each do |attribute|
    define_method("#{attribute}") do
      self.data ||= {}
      self.data[attribute]
    end

    define_method("#{attribute}=") do |value|
      self.data ||= {}
      self.data[attribute] = value
    end
  end

  def publish!
    update!(published_at: Time.now)
  end

  def published_on
    published_at.to_date
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

class Song < ActiveRecord::Base
  REMOTE_ATTRIBUTES = %w(id title duration artwork_url permalink_url).freeze
  LOCAL_ATTRIBUTES  = [REMOTE_ATTRIBUTES, "artist"].flatten.freeze

  scope :published, -> { where("published_at IS NOT NULL").order("published_at DESC") }

  validates_presence_of :data

  def self.create_from_remote(id)
    client = SoundCloud.new(client_id: ENV["SOUNDCLOUD_ID"])
    remote = client.get("/tracks/#{id}")

    return unless remote.streamable

    Song.new.tap do |song|
      song.update_from_remote(remote)
      song.save
    end
  rescue SoundCloud::ResponseError
  end

  def artist
    data["artist"]
  end

  def published_on
    published_at.to_date
  end

  def title
    data["title"]
  end

  def update_from_remote(remote)
    self.data = remote.with_indifferent_access.tap do |data|
      artist, title = data[:title].split(" - ", 2)

      data.slice!(*REMOTE_ATTRIBUTES)
      data[:title]    = title
      data[:artist]   = artist
      data[:duration] = (data[:duration] / 1000.0).round
    end
  end
end

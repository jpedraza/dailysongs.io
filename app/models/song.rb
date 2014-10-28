class Song < ActiveRecord::Base
  REMOTE_ATTRIBUTES = %w(id title duration artwork_url permalink_url).freeze

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

  def created_on
    created_at.to_date
  end

  def title
    data["title"]
  end

  def update_from_remote(remote)
    self.data = remote.with_indifferent_access.tap do |data|
      data.slice!(*REMOTE_ATTRIBUTES)
      data[:duration] /= 1000.0
    end
  end
end

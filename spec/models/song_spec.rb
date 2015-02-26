require "rails_helper"

describe Song do
  it { should validate_presence_of(:data) }

  it { should validate_presence_of(:remote_id) }
  it { should validate_numericality_of(:remote_id).only_integer }

  it { should validate_presence_of(:artist) }

  it { should validate_presence_of(:title) }

  it { should validate_presence_of(:duration) }
  it { should validate_numericality_of(:duration).only_integer }

  it { should validate_presence_of(:artwork_url) }

  it { should validate_presence_of(:permalink_url) }

  it { should validate_inclusion_of(:purchase_type).
                in_array(Song::PURCHASE_TYPES).allow_blank }
end

describe Song, ".build_from_remote" do
  subject { Song }

  let(:id)     { 172471838 }
  let(:song)   { double("song") }
  let(:error)  { SoundCloud::ResponseError.new(Rack::Response.new) }
  let(:client) { double("client") }
  let(:remote) { double("remote") }

  before do
    allow(song).to receive(:update_from_remote)
    allow(Song).to receive(:new).and_return(song)
    allow(client).to receive(:get).and_return(remote)
    allow(remote).to receive(:streamable).and_return(true)
    allow(SoundCloud).to receive(:new).and_return(client)
  end

  it "creates a SoundCloud client" do
    subject.build_from_remote(id)

    expect(SoundCloud).to have_received(:new).with(client_id: ENV["SOUNDCLOUD_ID"])
  end

  it "retrieves the remote song" do
    subject.build_from_remote(id)

    expect(client).to have_received(:get).with("/tracks/#{id}")
  end

  it "handles invalid retrieval of remote song" do
    allow(client).to receive(:get).and_raise(error)

    expect {
      subject.build_from_remote(id)
    }.to_not raise_error
  end

  it "initializes a new song" do
    subject.build_from_remote(id)

    expect(Song).to have_received(:new)
  end

  it "updates the song from the remote" do
    subject.build_from_remote(id)

    expect(song).to have_received(:update_from_remote).with(remote)
  end

  it "does not initialize a new song when remote is not streamable" do
    allow(remote).to receive(:streamable).and_return(false)

    result = subject.build_from_remote(id)

    expect(Song).to_not have_received(:new)
    expect(result).to be_nil
  end

  it "does not initialize a new song when ID is nil" do
    result = subject.build_from_remote(nil)

    expect(Song).to_not have_received(:new)
    expect(result).to be_nil
  end
end

describe Song, ".publish!" do
  subject { Song }

  let!(:song_1)       { create(:song) }
  let!(:song_2)       { create(:song) }
  let!(:invalid_song) { create(:song) }

  before do
    invalid_song.title = ""
    invalid_song.save(validate: false)
  end

  it "publishes the songs" do
    subject.publish!(song_1.id, song_2.id)

    expect(song_1.reload.published_on).to_not be_nil
    expect(song_2.reload.published_on).to_not be_nil
  end

  it "publishes the songs in a transaction" do
    expect {
      subject.publish!(song_1.id, invalid_song.id)
    }.to raise_error(ActiveRecord::RecordInvalid)

    expect(song_1.reload.published_on).to be_nil
    expect(invalid_song.reload.published_on).to be_nil
  end
end

describe Song, ".published" do
  subject { Song }

  let!(:published_song)   { create(:song, :published) }
  let!(:unpublished_song) { create(:song) }

  it "includes published songs" do
    expect(subject.published).to include(published_song)
  end

  it "excludes unpublished songs" do
    expect(subject.published).to_not include(unpublished_song)
  end
end

describe Song, ".published_before" do
  subject { Song }

  let!(:song_1) { create(:song, published_on: Date.today) }
  let!(:song_2) { create(:song, published_on: Date.today - 1.day) }
  let!(:song_3) { create(:song, published_on: Date.today - 2.days) }

  it "only includes songs published on or before the provided date" do
    expect(subject.published_before(song_2.published_on)).to eq([
      song_2, song_3
    ])
  end
end

describe Song, ".unpublished" do
  subject { Song }

  let!(:published_song)   { create(:song, :published) }
  let!(:unpublished_song) { create(:song) }

  it "includes unpublished songs" do
    expect(subject.unpublished).to include(unpublished_song)
  end

  it "excludes published songs" do
    expect(subject.unpublished).to_not include(published_song)
  end
end

describe Song, "#artwork_url" do
  subject { build(:song, data: { artwork_url: url }) }

  let(:url)      { "https://i1.sndcdn.com/artworks-000093571575-bx17w9-large.jpg" }
  let(:crop_url) { "https://i1.sndcdn.com/artworks-000093571575-bx17w9-crop.jpg" }

  it "returns the data value by default" do
    expect(subject.artwork_url).to eq(url)
  end

  it "supports custom styles" do
    expect(subject.artwork_url(:crop)).to eq(crop_url)
  end
end

describe Song, "#publish!" do
  subject { create(:song) }

  it "publishes the song" do
    subject.publish!

    expect(subject.reload.published_on).to_not be_nil
  end

  it "raises if record is invalid" do
    subject.title = nil

    expect {
      subject.publish!
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

describe Song, "#update_from_remote" do
  subject { build(:song) }

  let(:local) { build(:local_song, duration: 121) }
  let(:remote) { build(:remote_song, duration: 120_500) }

  it "assigns remote attributes to JSON data" do
    subject.update_from_remote(remote)

    subject.data.keys.each do |key|
      expect(key).to be_in(Song::LOCAL_ATTRIBUTES)
    end
  end

  it "attempts to separate artist and title" do
    subject.update_from_remote(remote)

    expect(subject.data).to eq(local)
  end

  it "converts the duration to seconds" do
    subject.update_from_remote(remote)

    expect(subject.data["duration"]).to eq(local["duration"])
  end
end

Song::LOCAL_ATTRIBUTES.each do |attribute|
  describe Song, "##{attribute}" do
    subject { build(:song) }

    it "returns the #{attribute} in the data" do
      result = subject.public_send(attribute)

      expect(result).to eq(subject.data[attribute])
    end
  end

  describe Song, "##{attribute}=" do
    subject { Song.new }

    let(:value) { build(:song).public_send(attribute) }

    it "updates the #{attribute} in the data" do
      subject.public_send("#{attribute}=", value)

      expect(subject.data[attribute]).to eq(value)
    end
  end
end

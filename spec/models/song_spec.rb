require "rails_helper"

describe Song do
  it { should validate_presence_of(:data) }
end

describe Song, ".create_from_remote" do
  subject { Song }

  let(:id)     { 172471838 }
  let(:song)   { double("song") }
  let(:error)  { SoundCloud::ResponseError.new(Rack::Response.new) }
  let(:client) { double("client") }
  let(:remote) { double("remote") }

  before do
    allow(song).to receive(:save)
    allow(song).to receive(:update_from_remote)
    allow(Song).to receive(:new).and_return(song)
    allow(client).to receive(:get).and_return(remote)
    allow(remote).to receive(:streamable).and_return(true)
    allow(SoundCloud).to receive(:new).and_return(client)
  end

  it "creates a SoundCloud client" do
    subject.create_from_remote(id)

    expect(SoundCloud).to have_received(:new).with(client_id: ENV["SOUNDCLOUD_ID"])
  end

  it "retrieves the remote song" do
    subject.create_from_remote(id)

    expect(client).to have_received(:get).with("/tracks/#{id}")
  end

  it "handles invalid retrieval of remote song" do
    allow(client).to receive(:get).and_raise(error)

    expect {
      subject.create_from_remote(id)
    }.to_not raise_error
  end

  it "initializes a new song" do
    subject.create_from_remote(id)

    expect(Song).to have_received(:new)
  end

  it "does not initialize a new song when remote is not streamable" do
    allow(remote).to receive(:streamable).and_return(false)

    subject.create_from_remote(id)

    expect(Song).to_not have_received(:new)
  end

  it "updates the song from the remote" do
    subject.create_from_remote(id)

    expect(song).to have_received(:update_from_remote).with(remote)
  end

  it "saves the song" do
    subject.create_from_remote(id)

    expect(song).to have_received(:save)
  end
end

describe Song, "#artist" do
  subject { build(:song) }

  it "returns the artist in the data" do
    expect(subject.artist).to eq(subject.data["artist"])
  end
end

describe Song, "#created_on" do
  subject { create(:song) }

  it "returns creation time as a date" do
    expect(subject.created_on).to eq(subject.created_at.to_date)
  end
end

describe Song, "#title" do
  subject { build(:song) }

  it "returns the title in the data" do
    expect(subject.title).to eq(subject.data["title"])
  end
end

describe Song, "#update_from_remote" do
  subject { build(:song) }

  let(:local) { build(:local_song, duration: 121) }
  let(:remote) { build(:remote_song, duration: 120_500) }

  it "assigns remote attributes to JSON data" do
    subject.update_from_remote(remote)

    expect(subject.data.keys).to eq(Song::LOCAL_ATTRIBUTES)
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

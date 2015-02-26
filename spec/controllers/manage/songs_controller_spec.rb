require "rails_helper"

describe Manage::SongsController, "#index" do
  let!(:published_song)   { create(:song, :published) }
  let!(:unpublished_song) { create(:song) }

  before do
    get :index
  end

  it { should respond_with(200) }
  it { should render_template(:index) }

  it "assigns published songs, in groups" do
    expect(assigns(:groups)).to eq({ Date.today => [published_song] })
  end

  it "assigns unpublished songs" do
    expect(assigns(:unpublished)).to eq([unpublished_song])
  end
end

describe Manage::SongsController, "#new" do
  let(:id)   { "1234" }
  let(:song) { build_stubbed(:song) }

  before do
    allow(Song).to receive(:build_from_remote).with(id).and_return(song)

    get :new, id: id
  end

  it { should respond_with(200) }
  it { should render_template(:new) }

  it "builds a song from the remote ID" do
    expect(Song).to have_received(:build_from_remote).with(id)
  end

  it "assigns the song" do
    expect(assigns(:song)).to eq(song)
  end
end

describe Manage::SongsController, "#create, when valid" do
  let(:attributes) { build(:local_song) }

  before do
    post :create, song: attributes
  end

  it { should redirect_to(manage_root_path) }

  it "creates a song" do
    song = Song.first

    expect(song).to_not be_nil
    expect(song.data).to eq(attributes)
  end
end

describe Manage::SongsController, "#create, when invalid" do
  before do
    post :create, song: { duration: nil }
  end

  it { should respond_with(200) }
  it { should render_template(:new) }

  it "does not create a song" do
    expect(Song.count).to eq(0)
  end
end

describe Manage::SongsController, "#edit" do
  let(:song) { create(:song) }

  before do
    get :edit, id: song.id
  end

  it { should respond_with(200) }
  it { should render_template(:edit) }

  it "assigns the song" do
    expect(assigns(:song)).to eq(song)
  end
end

describe Manage::SongsController, "#update, when valid" do
  let(:song)  { create(:song) }
  let(:title) { "New Title" }

  before do
    post :update, id: song.id, song: { title: title }
  end

  it { should redirect_to(manage_root_path) }

  it "updates the song" do
    expect(song.reload.title).to eq(title)
  end
end

describe Manage::SongsController, "#update, when invalid" do
  let(:song) { create(:song) }

  before do
    post :update, id: song.id, song: { title: "" }
  end

  it { should respond_with(200) }
  it { should render_template(:edit) }

  it "does not update the song" do
    expect(song.reload.title).to_not be_empty
  end
end

describe Manage::SongsController, "#publish" do
  let(:song) { create(:song) }

  before do
    put :publish, ids: [song.id]
  end

  it { should redirect_to(manage_root_path) }

  it "publishes the songs" do
    expect(song.reload.published_at).to_not be_nil
  end
end

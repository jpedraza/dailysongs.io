require "rails_helper"

describe SongsController, "#index" do
  let!(:published_song)   { create(:song, :published) }
  let!(:unpublished_song) { create(:song) }

  before do
    get :index
  end

  it { should respond_with(200) }
  it { should render_template(:index) }

  it "only assigns published songs" do
    groups = assigns(:groups)
    songs  = groups[Date.today]

    expect(songs.length).to eq(1)
    expect(groups.length).to eq(1)
  end
end

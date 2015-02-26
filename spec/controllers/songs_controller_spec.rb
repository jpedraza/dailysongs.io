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
    expect(assigns(:groups)).to eq({ Date.today => [published_song] })
  end
end

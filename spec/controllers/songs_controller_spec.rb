require "rails_helper"

describe SongsController, "#index" do
  let!(:published_song)   { create(:song, :published) }
  let!(:unpublished_song) { create(:song) }

  before do
    get :index
  end

  it { should respond_with(200) }
  it { should render_template(:index) }

  it "only assigns group of published songs" do
    expect(assigns(:groups)).to eq({
      Date.today => [published_song]
    })
  end
end

describe SongsController, "#show" do
  let!(:song_4) { create(:song, published_on: Date.today - 3.days) }
  let!(:song_3) { create(:song, published_on: Date.today - 2.days) }
  let!(:song_2) { create(:song, published_on: Date.today - 1.day) }
  let!(:song_1) { create(:song, published_on: Date.today) }
  let!(:unpublished_song) { create(:song) }

  before do
    get :show, id: song_2.id
  end

  it { should respond_with(200) }
  it { should render_template(:index) }

  it "assigns the song" do
    expect(assigns(:song)).to eq(song_2)
  end

  it "assign group of songs published on or before requested song" do
    expect(assigns(:groups)).to eq({
      Date.today - 1.days => [song_2],
      Date.today - 2.days => [song_3],
      Date.today - 3.days => [song_4]
    })
  end

  it "orders songs by published date in descending order" do
    expect(assigns(:groups).values.flatten).to eq(
      [song_2, song_3, song_4]
    )
  end
end

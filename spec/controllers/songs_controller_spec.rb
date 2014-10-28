require "rails_helper"

describe SongsController, "#index" do
  before do
    get :index
  end

  it { should respond_with(200) }
  it { should render_template(:index) }
end

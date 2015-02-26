require "rails_helper"

describe SongsController do
  it { should route(:get, "/").to(action: :index) }
  it { should route(:get, "/songs/1").to(action: :show, id: 1) }
end

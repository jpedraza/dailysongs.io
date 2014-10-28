require "rails_helper"

describe SongsController do
  it { should route(:get, "/").to(action: :index) }
end

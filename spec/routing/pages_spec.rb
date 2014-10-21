require "rails_helper"

describe PagesController do
  it { should route(:get, "/").to(action: :index) }
end

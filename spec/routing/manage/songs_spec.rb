require "rails_helper"

describe Manage::SongsController do
  let(:base) { "http://manage.dailysongs.io" }

  it { should route(:get, "#{base}/").to(action: :index, subdomain: "manage") }

  it { should route(:get, "#{base}/songs/new").
                to(action: :new, subdomain: "manage") }

  it { should route(:post, "#{base}/songs").
                to(action: :create, subdomain: "manage") }

  it { should route(:get, "#{base}/songs/1/edit").
                to(action: :edit, id: 1, subdomain: "manage") }

  it { should route(:put, "#{base}/songs/1").
                to(action: :update, id: 1, subdomain: "manage") }

  it { should route(:put, "#{base}/songs/publish").
                to(action: :publish, subdomain: "manage") }
end

class SongsController < ApplicationController
  def index
    @groups = Song.published.group_by(&:published_on)
  end
end

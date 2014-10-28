class SongsController < ApplicationController
  def index
    @groups = Song.all.group_by(&:created_on)
  end
end

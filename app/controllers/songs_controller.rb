class SongsController < ApplicationController
  def index
    @groups = Song.published.group_by(&:published_on)
  end

  def show
    @song   = Song.published.find(params[:id])
    @groups = Song.published_before(@song.published_on).
      desc(:published_on).group_by(&:published_on)

    render :index
  end
end

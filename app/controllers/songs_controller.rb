class SongsController < ApplicationController
  COMPRESSOR = HtmlCompressor::Compressor.new(
    remove_intertag_spaces: true,
    remove_surrounding_spaces: HtmlCompressor::Compressor::BLOCK_TAGS_MIN
  )

  def index
    respond_to do |format|
      format.html do
        @songs = Song.published_on_or_before(Date.today).paginate
      end
      format.js do
        songs  = Song.published_before(params[:date]).paginate
        groups = songs.group_by(&:published_on)

        render text: COMPRESSOR.compress(
          render_to_string("_groups", locals: { groups: groups })
        )
      end
    end
  end

  def show
    @song  = Song.published.find(params[:id])
    @songs = Song.published_on_or_before(@song.published_on).paginate

    render :index
  end
end

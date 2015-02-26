class Manage::SongsController < ManageController
  def index
    @groups      = Song.published.group_by(&:published_on)
    @unpublished = Song.unpublished
  end

  def new
    @song = Song.build_from_remote(params[:id])
  end

  def create
    @song = Song.new(song_parameters)

    if @song.save
      redirect_to manage_root_path
    else
      render :new
    end
  end

  def edit
    @song = Song.find(params[:id])
  end

  def update
    @song = Song.find(params[:id])

    if @song.update_attributes(song_parameters)
      redirect_to manage_root_path
    else
      render :edit
    end
  end

  def publish
    Song.publish!(*params[:ids])

    redirect_to manage_root_path
  end

  protected

  def song_parameters
    params.require(:song).permit(Song::LOCAL_ATTRIBUTES).tap do |parameters|
      parameters[:duration]  = parameters[:duration].to_i
      parameters[:remote_id] = parameters[:remote_id].to_i
    end
  end
end

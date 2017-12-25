class ArtistsController < ApplicationController
  def index
    query = "MATCH (Name) AGAINST (\"#{params[:search]}\")"
    @artists = ArtistGroup.where(query).paginate(page: params[:page], per_page: 30)
  end

  def show
    @artist = ArtistGroup.find(params[:id])
    sort = params[:sort] || 'Name asc'
    @torrent_groups = @artist.torrent_groups(sort)
    @similar = @artist.similar
  end

  def random
    redirect_to action: :show, id: ArtistGroup.random.ArtistID
  end
end

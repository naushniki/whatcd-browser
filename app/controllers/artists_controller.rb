class ArtistsController < ApplicationController
  def index
    sort = params[:sort] || 'Name asc'
    if params[:search].to_s!=""
      query = "MATCH (Name) AGAINST (\"#{params[:search]}\")"
      @artists = ArtistGroup.where(query).paginate(page: params[:page], per_page: 30)
    else
      @artists = ArtistGroup.order(sort).paginate(page: params[:page], per_page: 30)
    end    
  end

  def show
    @artist = ArtistGroup.find(params[:id])
    sort = params[:sort] || 'Name asc'
    @torrent_groups = @artist.torrent_groups(sort)
    @similarity_nodes, @similarity_edges = @artist.construct_similarity_graph_for_given_level_of_separation(2)
  end

  def random
    redirect_to action: :show, id: ArtistGroup.random.ArtistID
  end
end

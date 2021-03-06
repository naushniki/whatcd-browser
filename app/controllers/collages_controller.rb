class CollagesController < ApplicationController
  def index
    sort = params[:sort] || 'Name asc'
    if params[:search].to_s!="" or params[:tag].to_s!=""
      query = String.new
      query += if params[:search]=="" then '' else "MATCH (Name) AGAINST (\"#{params[:search]}\") and " end
      query += if params[:tag]=="" then '' else "MATCH (taglist) AGAINST (\"#{params[:tag]}\" IN BOOLEAN MODE)" end
      if query.end_with?(" and ")
        5.times do
          query = query.chop
        end
      end
      @collages = Collage.where(query).paginate(page: params[:page], per_page: 30)
    else
      @collages = Collage.order(sort).paginate(page: params[:page], per_page: 30)
    end
  end

  def show
    @collage = Collage.find(params[:id])
    sort = params[:sort] || 'a.Name asc'
    @torrents = @collage.torrents(sort)
  end

  def random
    redirect_to action: :show, id: Collage.random.ID
  end
end

class GroupsController < ApplicationController
  def index
    sort = params[:sort] || 'Name asc'
    if params[:search].to_s!="" or params[:tag].to_s!="" or params[:label].to_s!=""
      query = String.new
      query += if params[:search]=="" then '' else "MATCH (Name) AGAINST (\"#{params[:search]}\") and " end
      query += if params[:label]=="" then '' else "MATCH (recordlabel) AGAINST (\"#{params[:label]}\" IN BOOLEAN MODE) and " end
      query += if params[:tag]=="" then '' else "MATCH (taglist) AGAINST (\"#{params[:tag]}\" IN BOOLEAN MODE)" end
      if query.end_with?(" and ")
        5.times do
          query = query.chop
        end
      end
      @groups = TorrentGroup.where("Name is not null").paginate(page: params[:page], per_page: 30)
    else
      @groups = TorrentGroup.order(sort).paginate(page: params[:page], per_page: 30)
    end
  end

  def show
    @group = TorrentGroup.find(params[:id])
    sort = params[:sort] || 'Media asc'
    @torrents = @group.torrents.order(sort).paginate(page: params[:page])
  end
end

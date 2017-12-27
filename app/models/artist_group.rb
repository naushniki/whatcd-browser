# == Schema Information
#
# Table name: artists_group
#
#  ArtistID :integer          not null, primary key
#  Name     :string(200)
#

class ArtistGroup < ActiveRecord::Base
  self.table_name = 'artists_group'

  def torrent_groups(order)
    TorrentGroup.find_by_sql("select * from torrents_group tg join torrents_artists ta on ta.ArtistID = #{self.ArtistID} and ta.GroupID = tg.id where tg.ArtistID = #{self.ArtistID} or ta.ArtistID = #{self.ArtistID} order by #{order}").uniq
  end

  def similar
    ArtistGroup.find_by_sql("
      select ag.*
      from artists_similar ar      
      join artists_similar ar2 on (ar.SimilarID=ar2.SimilarID and ar2.artistid!=ar.artistid)
      join artists_group ag on ag.artistid=ar2.artistid
      where ar.artistid=#{self.ArtistID.to_s}")
  end

  def load_top_similar_artists(limit=120)
    ArtistGroup.find_by_sql("
      select ag.*
      from artists_similar ar      
      join artists_similar ar2 on (ar.SimilarID=ar2.SimilarID and ar2.artistid!=ar.artistid)
      join artists_group ag on ag.artistid=ar2.artistid
      join artists_similar_scores sc on sc.SimilarID=ar.SimilarID      
      where ar.artistid=#{self.ArtistID.to_s}
      order by sc.score desc limit #{limit};")
  end

  #level - level of separation between artist and loaded similar artists.
  #limit - maximum amount of artists to be added on each level of separarion above 1. If limit value is greater,
  #than the existing number of artists for given level of separation, the ones with the lower scores get excluded.
  def construct_similarity_graph_for_given_level_of_separation(level, limit = 45)
    nodes = self.load_top_similar_artists()
    edges = Array.new
    nodes.each do |node|
      vals = [self.ArtistID, node.ArtistID].sort
      edge = {"from" => vals[0], "to" => vals[1]}
      edges.push(edge)
    end
    self.instance_variable_set(:@similar_artists_loaded, true)
    nodes.push(self)
    i = 1
    while i < level
      new_ids = nodes.map { |x| if !(x.instance_variable_get(:@similar_artists_loaded)==true) then x.ArtistID else nil end}.compact
      all_ids = nodes.map { |x| x.ArtistID }.compact
      data = load_connections(new_ids, all_ids, limit)
      nodes.each do |node|
        node.instance_variable_set(:@similar_artists_loaded, true)
      end
      ids_to_load = data.map { |entry| 
        if (!nodes.include?(ArtistGroup.new({:ArtistID => entry["ArtistID2"]})))
          entry["ArtistID2"]
        else nil end
        }.compact
      nodes += ArtistGroup.find(ids_to_load)
      data.each do |entry|
        vals = [entry["ArtistID1"], entry["ArtistID2"]].sort
        edge = {"from" => vals[0], "to" => vals[1]}  
        if (!edges.include?(edge) and nodes.include?(ArtistGroup.new({:ArtistID => entry["ArtistID2"]})) and nodes.include?(ArtistGroup.new({:ArtistID => entry["ArtistID1"]})))
          edges.push(edge)
        end
      end      
      i += 1
    end
    return nodes, edges
  end

  def load_connections(new_ids, all_ids, limit)    
    query = "
      select ar.artistid, ar2.artistid, sc.score
      from artists_similar ar      
      join artists_similar ar2 on (ar.SimilarID=ar2.SimilarID and ar2.artistid!=ar.artistid)
      join artists_group ag on ag.artistid=ar2.artistid
      join artists_similar_scores sc on sc.SimilarID=ar.SimilarID
      where ar.artistid in (#{new_ids.join(',')})
      order by sc.score desc limit #{limit};"   
      new_connections = ActiveRecord::Base.connection.execute(query)
                        .map {|x| {"ArtistID1" => x[0], "ArtistID2" => x[1], "score" => x[2]}}
    query = "
      select ar.artistid, ar2.artistid, sc.score
      from artists_similar ar      
      join artists_similar ar2 on (ar.SimilarID=ar2.SimilarID and ar2.artistid!=ar.artistid)
      join artists_group ag on ag.artistid=ar2.artistid
      join artists_similar_scores sc on sc.SimilarID=ar.SimilarID
      where ar.artistid in (#{new_ids.join(',')})
      and (ar2.artistid in (#{all_ids.join(',')}) 
      or ar2.artistid in (#{new_ids.join(',')}) 
      or ar2.artistid in (#{new_connections.map { |x| x["ArtistID2"] }.join(',')}))
      order by sc.score desc;"
      conections_to_existing_nodes = ActiveRecord::Base.connection.execute(query)
                        .map {|x| {"ArtistID1" => x[0], "ArtistID2" => x[1], "score" => x[2]}}
      return new_connections + conections_to_existing_nodes
  end

  def self.random
    total_rows = 885304 # this will never change
    ArtistGroup.offset(rand(total_rows)).limit(1).first
  end

  private :load_connections
end
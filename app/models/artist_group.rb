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

  def construct_similarity_graph_for_given_level_of_separation(level)
    nodes = self.similar
    edges = Array.new
    nodes.each do |node|
      edges.push({"from" => self.ArtistID, "to" => node.ArtistID})
    end
    self.instance_variable_set(:@similar_artists_loaded, true)
    nodes.push(self)
    i = 1
    while i <= level      
      nodes.clone.each do |node|
        next if defined? node.similar_artists_loaded
        new_nodes = node.similar
        new_nodes.each do |new_node|
          if !nodes.include?(new_node) and i < level
            nodes.push(new_node)
          end
          vals = [node.ArtistID, new_node.ArtistID].sort
          edge = {"from" => vals[0], "to" => vals[1]}
          if !edges.include?(edge)
            edges.push(edge)
          end
        end
        node.instance_variable_set(:@similar_artists_loaded, true)
      end
      i += 1
    end
    return nodes, edges
  end

  def self.random
    total_rows = 885304 # this will never change
    ArtistGroup.offset(rand(total_rows)).limit(1).first
  end
end

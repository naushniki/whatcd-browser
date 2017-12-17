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
    query = ActiveRecord::Base.connection.raw_connection.prepare("
            select ar2.artistid, ars.score, ag.name
            from artists_similar ar
            join artists_similar_scores ars on ars.SimilarID=ar.SimilarID
            join artists_similar ar2 on (ar.SimilarID=ar2.SimilarID and ar2.artistid!=ar.artistid)
            join artists_group ag on ag.artistid=ar2.artistid
            where ar.artistid=?")
    query.execute(self.ArtistID).to_a
  end

  def self.random
    total_rows = 885304 # this will never change
    ArtistGroup.offset(rand(total_rows)).limit(1).first
  end
end

class AddIndexesOnTorrentsGroup < ActiveRecord::Migration[5.0]
  
  def up
    execute "SET sql_mode = \'\';"
    execute "CREATE FULLTEXT INDEX torrents_group_name_index ON torrents_group(Name);"
    execute "CREATE FULLTEXT INDEX torrents_group_recordlabel_index ON torrents_group(RecordLabel);"
    execute "CREATE FULLTEXT INDEX torrents_group_TagList_index ON torrents_group(TagList);"
  end

  def down
    execute "SET sql_mode = \'\';"
    execute "DROP INDEX torrents_group_name_index ON torrents_group;"
    execute "DROP INDEX torrents_group_recordlabel_index ON torrents_group;"
    execute "DROP INDEX torrents_group_TagList_index ON torrents_group;"
  end

end
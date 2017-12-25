class AddIndexesOnCollages < ActiveRecord::Migration[5.0]
  
  def up
    execute "SET sql_mode = \'\';"
    execute "CREATE FULLTEXT INDEX collages_name_index ON collages(Name);"
    execute "CREATE FULLTEXT INDEX collages_TagList_index ON collages(TagList);"
  end

  def down
    execute "SET sql_mode = \'\';"
    execute "DROP INDEX collages_name_index ON collages;"
    execute "DROP INDEX collages_TagList_index ON torrents_group;"
  end

end
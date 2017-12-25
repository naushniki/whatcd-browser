class AddIndexesOnArtistsGroup < ActiveRecord::Migration[5.0]
  
  def up
    execute "SET sql_mode = \'\';"
    execute "CREATE FULLTEXT INDEX artists_group_name_index ON artists_group(Name);"
  end

  def down
    execute "SET sql_mode = \'\';"
    execute "DROP INDEX artists_group_name_index ON artists_group;"
  end

end
class PostSeasons < ActiveRecord::Migration[5.2]
  def change
  	add_reference :posts, :season, index: true
  end
end

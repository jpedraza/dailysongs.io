class AddPublishedAtToSongs < ActiveRecord::Migration
  def change
    change_table :songs do |t|
      t.datetime :published_at
      t.index    :published_at
    end
  end
end

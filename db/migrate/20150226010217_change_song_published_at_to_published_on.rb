class ChangeSongPublishedAtToPublishedOn < ActiveRecord::Migration
  def up
    change_table :songs do |t|
      t.date  :published_on
      t.index :published_on, order: "DESC"
    end

    execute "UPDATE songs SET published_on = DATE(published_at)"

    change_table :songs do |t|
      t.remove :published_at
    end
  end

  def down
    change_table :songs do |t|
      t.datetime :published_at
      t.index    :published_at
    end

    execute "UPDATE songs SET published_at = published_on"

    change_table :songs do |t|
      t.remove :published_on
    end
  end
end

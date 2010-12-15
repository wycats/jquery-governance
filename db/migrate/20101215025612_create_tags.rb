class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end

    create_table :taggings, :id => false do |t|
      t.belongs_to :tag
      t.belongs_to :motion
    end

    add_index :taggings, [:tag_id, :motion_id]
  end

  def down
    remove_index :taggings, :column => [:tag_id, :motion_id]

    drop_table :taggings

    drop_table :tags
  end
end

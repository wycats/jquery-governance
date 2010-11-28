class CreateEvents < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.belongs_to :member
      t.belongs_to :motion
      t.string :type
      t.boolean :value, :default => true

      t.timestamps
    end
  end

  def down
    drop_table :events
  end
end

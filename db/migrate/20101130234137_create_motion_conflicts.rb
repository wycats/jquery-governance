class CreateMotionConflicts < ActiveRecord::Migration
  def up
    create_table :motion_conflicts do |t|
      t.integer :motion_id
      t.integer :conflict_id

      t.timestamps
    end
  end

  def down
    drop_table :motion_conflicts
  end
end

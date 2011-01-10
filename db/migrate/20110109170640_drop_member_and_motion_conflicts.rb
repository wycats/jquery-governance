class DropMemberAndMotionConflicts < ActiveRecord::Migration
  def up
    drop_table :member_conflicts
    drop_table :motion_conflicts
  end

  def down
    create_table :motion_conflicts do |t|
      t.integer :motion_id
      t.integer :conflict_id

      t.timestamps
    end
     
    create_table :member_conflicts do |t|
      t.integer :member_id
      t.integer :conflict_id

      t.timestamps
    end
  end
end

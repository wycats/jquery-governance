class CreateMemberConflicts < ActiveRecord::Migration
  def up
    create_table :member_conflicts do |t|
      t.integer :member_id
      t.integer :conflict_id

      t.timestamps
    end
  end

  def down
    drop_table :member_conflicts
  end
end

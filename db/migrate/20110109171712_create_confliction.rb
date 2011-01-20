class CreateConfliction < ActiveRecord::Migration
  def up
    create_table :conflictions do |t|
      t.references :conflict
      t.references :conflictable, :polymorphic => true

      t.datetime :created_at
    end

    add_index :conflictions, :conflict_id
    add_index :conflictions, [:conflictable_id, :conflictable_type]
  end


  def down
    drop_table :conflictions
  end
end

class CreateConflicts < ActiveRecord::Migration
  def up
    create_table :conflicts do |t|
      t.string :title

      t.timestamps
    end
  end

  def down
    drop_table :conflicts
  end
end

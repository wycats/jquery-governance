class CreateMembers < ActiveRecord::Migration
  def up
    create_table :members do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :members
  end
end

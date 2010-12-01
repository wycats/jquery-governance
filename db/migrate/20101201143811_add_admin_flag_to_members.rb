class AddAdminFlagToMembers < ActiveRecord::Migration
  def up
    change_table :members do |t|
      t.boolean :is_admin
    end
  end

  def down
    change_table :members do |t|
      t.remove :is_admin
    end
  end
end

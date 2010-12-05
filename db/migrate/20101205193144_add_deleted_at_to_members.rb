class AddDeletedAtToMembers < ActiveRecord::Migration
  def up
    add_column :members, :deleted_at, :datetime
  end

  def down
    remove_column :members, :deleted_at
  end
end

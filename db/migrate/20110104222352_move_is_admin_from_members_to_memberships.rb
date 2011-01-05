class MoveIsAdminFromMembersToMemberships < ActiveRecord::Migration
  def up
    remove_column :members, :is_admin
    add_column :memberships, :is_admin, :boolean
  end

  def down
    remove_column :memberships, :is_admin
    add_column :members, :is_admin, :boolean
  end
end

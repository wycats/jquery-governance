class RenameActiveMembershipStartEndColumns < ActiveRecord::Migration
  def up
    rename_column :active_memberships, :start_time, :started_at
    rename_column :active_memberships, :end_time,   :ended_at
  end

  def down
    rename_column :active_memberships, :started_at, :start_time
    rename_column :active_memberships, :ended_at,   :end_time
  end
end

class AddMotionForeignKeysToActiveMemberships < ActiveRecord::Migration
  def up
    add_column :active_memberships, :qualifying_motion_id, :integer
    add_column :active_memberships, :disqualifying_motion_id, :integer
  end

  def down
    remove_column :active_memberships, :disqualifying_motion_id
    remove_column :active_memberships, :qualifying_motion_id
  end
end

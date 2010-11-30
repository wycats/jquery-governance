class TimesBegone < ActiveRecord::Migration
  def up
    change_column :active_memberships, :start_time, :datetime
    change_column :active_memberships, :end_time, :datetime
  end

  def down
    change_column :active_memberships, :start_time, :time
    change_column :active_memberships, :end_time, :time
  end
end

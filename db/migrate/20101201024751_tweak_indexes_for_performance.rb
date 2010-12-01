class TweakIndexesForPerformance < ActiveRecord::Migration
  def up
    # Add Index to Events, for speedier lookup of validations
    add_index :events, [:member_id, :motion_id, :event_type], :unique => true,
                                                              :name   => :event_validation_of_member_event_type

    # Add index to Member/EventType and Motion/EventType pairs
    add_index :events, [:member_id, :event_type], :name => :member_events_by_event_type
    add_index :events, [:motion_id, :event_type], :name => :motion_events_by_event_type

    # Add index to Motion/Value (vote) pair
    add_index :events, [:motion_id, :value],      :name => :motion_events_by_value

    # Add Index to Active Memberships on start + end dates
    add_index :active_memberships, [:started_at]
    add_index :active_memberships, [:ended_at]

    # Add Index to Active Memberships on member_id
    add_index :active_memberships, [:member_id]

    # Add Index to Motions on member_id
    add_index :motions, [:member_id]
  end

  def down
    remove_index :events, :name => :event_validation_of_member_event_type
    remove_index :events, :name => :member_events_by_event_type
    remove_index :events, :name => :motion_events_by_event_type
    remove_index :events, :name => :motion_events_by_value

    remove_index :active_memberships, :column => :started_at
    remove_index :active_memberships, :column => :ended_at
    remove_index :active_memberships, :column => :member_id

    remove_index :motions, :column => :member_id
  end
end

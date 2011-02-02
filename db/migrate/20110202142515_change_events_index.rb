class ChangeEventsIndex < ActiveRecord::Migration
  def self.up
    remove_index :events, :name => :event_validation_of_member_event_type
    add_index :events, [:member_id, :motion_id, :event_type], :name => :event_validation_of_member_event_type
  end

  def self.down
    remove_index :events, :name => :event_validation_of_member_event_type
    add_index :events, [:member_id, :motion_id, :event_type], :unique => true,
                                                              :name   => :event_validation_of_member_event_type
  end
end

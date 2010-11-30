class RenameEventsTypeColumn < ActiveRecord::Migration
  def up
    rename_column :events, :type, :event_type
  end

  def down
    rename_column :events, :event_type, :type
  end
end

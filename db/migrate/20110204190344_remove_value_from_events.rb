class RemoveValueFromEvents < ActiveRecord::Migration
  def self.up
    execute "UPDATE events SET event_type='yes_vote' WHERE event_type='vote' AND value='t'"
    execute "UPDATE events SET event_type='no_vote' WHERE event_type='vote' AND value='f'"
    remove_column :events, :value
  end

  def self.down
    add_column :events, :value, :boolean, :default => true
    execute "UPDATE events SET event_type='vote', value='t' WHERE event_type='yes_vote'"
    execute "UPDATE events SET event_type='vote', value='f' WHERE event_type='no_vote'"
  end
end

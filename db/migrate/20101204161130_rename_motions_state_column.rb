class RenameMotionsStateColumn < ActiveRecord::Migration
  def up
    rename_column :motions, :state, :state_name
  end

  def down
    rename_column :motions, :state_name, :state
  end
end

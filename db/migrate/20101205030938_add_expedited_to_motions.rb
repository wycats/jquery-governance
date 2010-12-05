class AddExpeditedToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :expedited, :boolean, :default => false
  end

  def down
    remove_column :motions, :expedited, :boolean
  end
end

class AddPublicToMotions < ActiveRecord::Migration
  def self.up
    add_column :motions, :public, :boolean, :default => false
  end

  def self.down
    remove_column :motions, :public
  end
end

class AddClosedAtToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :closed_at, :datetime
  end

  def down
    remove_column :motions, :closed_at
  end
end

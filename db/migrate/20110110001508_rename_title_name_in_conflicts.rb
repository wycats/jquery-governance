class RenameTitleNameInConflicts < ActiveRecord::Migration
  def up
    rename_column :conflicts, :title, :name
  end

  def down
    rename_column :conflicts, :name, :title
  end
end

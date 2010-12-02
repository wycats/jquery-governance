class ChangeMotionsStateDefault < ActiveRecord::Migration
  def up
    change_table :motions do |t|
      t.change :state, :string, :default => nil
    end
  end

  def down
    change_table :motions do |t|
      t.change :state, :string, :default => "waitingsecond"
    end
  end
end

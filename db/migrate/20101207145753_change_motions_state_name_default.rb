class ChangeMotionsStateNameDefault < ActiveRecord::Migration
  def up
    change_column_default :motions, :state_name, 'waitingsecond'
  end

  def down
    change_column_default :motions, :state_name, nil
  end
end

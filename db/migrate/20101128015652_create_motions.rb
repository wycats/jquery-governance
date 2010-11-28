class CreateMotions < ActiveRecord::Migration
  def up
    create_table :motions do |t|
      t.belongs_to :member
      t.string :title
      t.string :state, :default => "waitingsecond"
      t.text :description, :rationale
      t.integer :abstains

      t.timestamps
    end
  end

  def down
    drop_table :motions
  end
end

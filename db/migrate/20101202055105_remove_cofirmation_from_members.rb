class RemoveCofirmationFromMembers < ActiveRecord::Migration
  def up
    change_table :members do |t|
      t.remove :token_confirmation
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
    end
  end

  def down
    change_table :members do |t|
      t.string :token_confirmation
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end
  end
end

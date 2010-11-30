class DeviseCreateMembers < ActiveRecord::Migration
  def self.up
    change_table(:members) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      

      # anything below to be uncommented would need a touch to self.down
      # t.trackable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      # t.confirmable
      
      

    end

    add_index :members, :email,                :unique => true
    add_index :members, :reset_password_token, :unique => true
    # add_index :members, :unlock_token,         :unique => true
  end

  def self.down
    change_table(:members) do |t|
      t.remove_index :email
      t.remove_index :reset_password_token
      t.remove :email, :encrypted_password, :password_salt, :reset_password_token, :remember_token, :remember_created_at
    end
  end
end

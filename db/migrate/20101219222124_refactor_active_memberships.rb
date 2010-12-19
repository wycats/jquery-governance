class RefactorActiveMemberships < ActiveRecord::Migration
  def up
    # Add Index to Active Memberships on start + end dates
    remove_index :active_memberships, :started_at
    remove_index :active_memberships, :ended_at

    # Add Index to Active Memberships on member_id
    remove_index :active_memberships, :member_id

    rename_table :active_memberships, :memberships

    # Add Index to Active Memberships on start + end dates
    add_index :memberships, [:started_at]
    add_index :memberships, [:ended_at]

    # Add Index to Active Memberships on member_id
    add_index :memberships, [:member_id]
  end

  def down
    # Add Index to Active Memberships on start + end dates
    remove_index :memberships, :started_at
    remove_index :memberships, :ended_at

    # Add Index to Active Memberships on member_id
    remove_index :memberships, :member_id

    rename_table :memberships, :active_memberships

    # Add Index to Active Memberships on start + end dates
    add_index :active_memberships, [:started_at]
    add_index :active_memberships, [:ended_at]

    # Add Index to Active Memberships on member_id
    add_index :active_memberships, [:member_id]

  end
end

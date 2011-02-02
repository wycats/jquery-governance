class AddCommentToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :comment, :text
  end

  def self.down
    remove_column :events, :comment
  end
end

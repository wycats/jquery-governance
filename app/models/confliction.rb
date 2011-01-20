class Confliction < ActiveRecord::Base
  belongs_to :conflict
  belongs_to :conflictable, :polymorphic => true

  validates :conflict_id, :uniqueness => {:scope => [:conflictable_type, :conflictable_id]},
                          :presence => true
end

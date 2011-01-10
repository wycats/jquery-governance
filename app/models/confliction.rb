class Confliction < ActiveRecord::Base
  belongs_to :conflict
  belongs_to :conflictable, :polymorphic => true
end

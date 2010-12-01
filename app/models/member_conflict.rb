class MemberConflict < ActiveRecord::Base
  belongs_to :conflict
  belongs_to :member
end

class Event < ActiveRecord::Base
  belongs_to  :member
  belongs_to  :motion
  validates   :member_id, :uniqueness => {
                            :scope => :motion_id
                          }
end

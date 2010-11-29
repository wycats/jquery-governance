class Second < Event
  validates :member_id, :presence   =>  true,
                        :uniqueness =>  {
                          :scope => :motion_member_id
                        }
end

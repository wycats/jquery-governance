member = Factory.create(:member)
Factory.create(:active_membership, :member => member)

module ActiveMember
  def active_member
    Member.first
  end
end

World(ActiveMember)

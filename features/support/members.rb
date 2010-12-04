member = Factory.create(:member)
Factory.create(:active_membership, member: member)

Factory(:member) # inactive member

module Members
  def active_member
    Member.find(1)
  end

  def inactive_member
    Member.find(2)
  end
end

World(Members)

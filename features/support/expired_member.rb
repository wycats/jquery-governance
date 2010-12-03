member = Factory.create(:member)
Factory.create(:expired_membership, :member => member)

module ExpiredMember
  def expired_member
    Member.first
  end
end

World(ExpiredMember)

class MotionSorter
  attr_reader :scope

  def initialize(scope=Motion.scoped)
    @scope = scope
  end

  # Find motions that are currently being voted and already closed grouped by
  # state.
  # @return [Hash] An entry for every group is in it, the key is the state name and the value are the motions.
  def public_groups
    { :voting => scope.voting, :closed => scope.closed }
  end

  # Find motions that are currently in the open states grouped by state.
  # @return [Hash] An entry for every group is in it, the key is the state name and the value are the motions.
  def open_groups
    { :waitingsecond => scope.waitingsecond, :discussing => scope.discussing, :voting => scope.voting }
  end

  # Find motions that are currently in the closed state.
  # @return [Hash] The key is the state name and the value are the motions.
  def closed_groups
    { :closed => scope.closed }
  end

  def all_groups
    open_groups.merge(closed_groups)
  end

  # Return the motion groups based on the user who is requesting them
  # @param [Member] user The user who is requesting the motion groups
  # @return [Hash] :groups returns the actual groups, and :name returns the name of the group
  def self.groups_for(member, options={})
    options.reverse_merge!(:scope => Motion.paginate, :groups => :all)
    motion_sorter = MotionSorter.new(options[:scope])
    groups = member.try(:membership_active?) ? options[:groups] : :public
    { :groups => motion_sorter.public_send("#{groups}_groups"), :name => groups }
  end
end

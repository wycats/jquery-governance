class MotionSorter
  # Return the motion groups based on the user who is requesting them
  # @param [Member] user The user who is requesting the motion groups
  # @return [Hash] :groups returns the actual groups, and :name returns the name of the group
  def self.group_for(member, group_options={})
    group_options.reverse_merge!(:scope => Motion.paginate, :name => :all)

    states = Motion.states(group_options[:name])
    unless member.try(:membership_active?)
      states.keep_if { |state| Motion.states(:public).include?(state) }
    end

    {
      :motions => hash_for(states, group_options[:scope]),
      :name    => group_options[:name]
    }
  end

private

  def self.hash_for(states, scope)
    state_pairs = states.map do |state|
      [state.to_sym, scope.public_send(state)]
    end

    Hash[state_pairs]
  end
end

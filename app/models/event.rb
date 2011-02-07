class Event < ActiveRecord::Base
  EVENT_TYPES = ["yes_vote", "no_vote", "second", "objection", "objection_withdrawn", "comment"]

  belongs_to  :member
  belongs_to  :motion

  validates   :member_id,   :uniqueness => {
                              :scope => [:motion_id, :event_type]
                            },
                            :unless => :comment?
  validates   :event_type,  :presence   => true,
                            :inclusion  => {
                              :in => EVENT_TYPES
                            }

  validate    :motion_creator_cannot_second,  :if => :second?
  after_create :update_waitingsecond_motion, :if => :second?
  after_create :update_discussing_motion, :if => :objection_withdrawn?

  scope :votes,   where(:event_type  => %w(yes_vote no_vote))
  scope :yes_votes, where(:event_type => 'yes_vote')
  scope :no_votes, where(:event_type => 'no_vote')
  scope :seconds,    where(:event_type  => "second")
  scope :objections, where(:event_type  => "objection")
  scope :objection_withdrawns, where(:event_type => 'objection_withdrawn')
  scope :for_motion, lambda { |motion_id| where(:motion_id => motion_id) }

  # @return [true, false] Whether or not this is a Voting Event
  def vote?
    %w(yes_vote no_vote).include?(event_type)
  end

  # @return [true, false] Whether or not this is a Seconding Event
  def second?
    event_type == "second"
  end

  # @return [true, false] Whether or not this is a Objecting Event
  def objection?
    event_type == "objection"
  end

  def objection_withdrawn?
    event_type == 'objection_withdrawn'
  end

  def comment?
    event_type == 'comment'
  end

private
  # Will error if the motion creator attempts to second their motion
  def motion_creator_cannot_second
    errors.add(:member, "Member cannot second a motion that they created.") if motion.member == member
  end

  def update_waitingsecond_motion
    return unless motion.waitingsecond?
    if motion.expedited?
      motion.voting! if motion.can_expedite?
    else
      motion.discussing! if motion.can_discuss?
    end
  end

  def update_discussing_motion
    return unless motion.discussing?
    motion.voting! if !motion.objected? && motion.updated_at <= Time.now - 1.day
  end
end

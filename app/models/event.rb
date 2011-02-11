class Event < ActiveRecord::Base
  EVENT_TYPES = ["yes_vote", "no_vote", "second", "objection", "objection_withdrawn", "comment", "withdrawn"]

  belongs_to  :member
  belongs_to  :motion

  validates :event_type, :presence => true, :inclusion => { :in => EVENT_TYPES }
  validates :member_id, :presence => true
  validates :motion_id, :presence => true

  validate :validate_event_action

  before_create :define_visibility

  after_create :update_waitingsecond_motion, :if => :second?
  after_create :update_discussing_motion, :if => :objection_withdrawn?
  after_create :close_motion, :if => :withdrawn?

  scope :votes,   where(:event_type  => %w(yes_vote no_vote))
  scope :yes_votes, where(:event_type => 'yes_vote')
  scope :no_votes, where(:event_type => 'no_vote')
  scope :seconds,    where(:event_type  => "second")
  scope :objections, where(:event_type  => "objection")
  scope :objection_withdrawns, where(:event_type => 'objection_withdrawn')
  scope :for_motion, lambda { |motion_id| where(:motion_id => motion_id) }
  scope :publicly_viewable, where(:public => true)

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

  def withdrawn?
    event_type == 'withdrawn'
  end

  def allowed?
    motion.permit?(action, member)
  end

  def action
    case event_type.to_sym
    when :second, :comment    then event_type.to_sym
    when :withdrawn           then :withdraw
    when :objection           then :object
    when :objection_withdrawn then :withdraw_objection
    when :yes_vote, :no_vote  then :vote
    end
  end

private

  def validate_event_action
    errors.add(:member, "Member is not allowed to do this.") unless allowed?
  end

  def define_visibility
    self.public = motion.public?
    true
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

  def close_motion
    motion.closed!
  end
end

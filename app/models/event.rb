class Event < ActiveRecord::Base
  # if more types are added, make sure to update app/views/events/_event,
  # which currently assumes the #{event}ed always converts an event to
  # its past tense form
  EVENT_TYPES = ["vote", "second"]
  HUMAN_READABLE_EVENT_TYPES = {
    'vote' => 'Vote',
    'second' => 'Second'
  }

  belongs_to  :member
  belongs_to  :motion

  validates   :member_id,   :uniqueness => {
                              :scope => [:motion_id, :event_type]
                            }
  validates   :event_type,  :presence   => true,
                            :inclusion  => {
                              :in => EVENT_TYPES
                            }

  validate    :motion_creator_cannot_second,  :if => :is_second?

  after_save  do
    motion.assert_state
  end

  scope :votes,   where(:event_type  => "vote") do
    # @return [ActiveRecord::Relation] An Array-like structure, of all aye-votes cast
    def yeas
      where :value => true
    end

    # @return [ActiveRecord::Relation] An Array-like structure, of all nay-votes cast
    def nays
      where :value => false
    end
  end

  scope :seconds, where(:event_type  => "second")

  # @return [true, false] Whether or not this is a Voting Event
  def is_vote?
    event_type == "vote"
  end
  alias :vote? :is_vote?

  # @return [true, false] Whether or not this is a Seconding Event
  def is_second?
    event_type == "second"
  end
  alias :second? :is_second?

  def formatted_event_type(format = :human)
    if format == :human
      HUMAN_READABLE_EVENT_TYPES[event_type]
    else
      event_type
    end
  end

private
  # Will error if the motion creator attempts to second their motion
  def motion_creator_cannot_second
    errors.add(:member, "Member cannot second a motion that they created.") if motion.member == member
  end
end

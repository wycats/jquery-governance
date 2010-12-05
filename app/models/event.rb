class Event < ActiveRecord::Base
  EVENT_TYPES = ["vote", "second", "objection"]

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
    motion.update_state
  end


  scope :votes,      where(:event_type  => "vote")
  scope :seconds,    where(:event_type  => "second")
  scope :objections, where(:event_type  => "objection")

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

  # @return [true, false] Whether or not this is a Objecting Event
  def is_objection?
    event_type == "objection"
  end
  alias :objection? :is_objection?

  # @return [ActiveRecord::Relation] An Array-like structure, of all aye-votes cast
  def self.yeas
    where :value => true
  end

  # @return [ActiveRecord::Relation] An Array-like structure, of all nay-votes cast
  def self.nays
    where :value => false
  end

private
  # Will error if the motion creator attempts to second their motion
  def motion_creator_cannot_second
    errors.add(:member, "Member cannot second a motion that they created.") if motion.member == member
  end
end

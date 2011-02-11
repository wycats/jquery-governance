class MotionGroup
  attr_reader :name

  def initialize(name, scope, *collection_names)
    @name, @scope, @collection_names = name, scope, collection_names
  end

  def collections
    collection_pairs = @collection_names.map do |collection_name|
      motions = @scope.public_send(collection_name)
      [collection_name, motions] if name != :search || motions.any?
    end
    Hash[collection_pairs.compact]
  end

  def empty?
    collections.empty?
  end

  def self.open
    new :open, Motion.paginate, :waitingsecond, :discussing, :voting
  end

  def self.closed
    new :closed, Motion.paginate.closed, :publicly_viewable, :privately_viewable
  end

  def self.publicly_viewable
    new :publicly_viewable, Motion.paginate.publicly_viewable, :voting, :closed
  end

  def self.search(keywords, member=nil)
    scope = Motion.search(keywords)
    scope = scope.publicly_viewable unless member.try(:membership_active?)
    new :search, scope, *Motion::MOTION_STATES.map(&:to_sym)
  end
end

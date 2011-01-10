class Conflict < ActiveRecord::Base

  validates :name, :presence => true

  def ==(object)
    super || (object.is_a?(Conflict) && name == object.name)
  end

  def to_s
    name
  end
end

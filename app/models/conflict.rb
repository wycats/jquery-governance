class Conflict < ActiveRecord::Base

  validates :name, :presence => true, :uniqueness => true

  def self.named(name)
    where(["name ILIKE ?", name])
  end

  def self.named_any(list)
    where(list.map { |conflict| sanitize_sql(["name ILIKE ?", conflict.to_s]) }.join(" OR "))
  end

  def self.named_like(name)
    where(["name ILIKE ?", "%#{name}%"])
  end

  def self.named_like_any(list)
    where(list.map { |conflict| sanitize_sql(["name ILIKE ?", "%#{conflict.to_s}%"]) }.join(" OR "))
  end

  def ==(object)
    super || (object.is_a?(Conflict) && name == object.name)
  end

  def to_s
    name
  end
end

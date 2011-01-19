class Conflict < ActiveRecord::Base
  has_many :conflictions

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

  def self.find_or_create_with_named_like(name)
    named_like(name).first || create(:name => name)
  end

  def self.find_or_create_all_with_like_by_name(*list)
    list = [list].flatten

    return [] if list.empty?

    existing_conflicts = Conflict.named_any(list).all
    new_conflict_names = list.reject { |name| existing_conflicts.any? { |conflict| conflict.name.mb_chars.downcase == name.mb_chars.downcase } }
    created_conflicts  = new_conflict_names.map { |name| Conflict.create(:name => name) }

    existing_conflicts + created_conflicts
  end

  def ==(object)
    super || (object.is_a?(Conflict) && name == object.name)
  end

  def to_s
    name
  end
end

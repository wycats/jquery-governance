class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :motions, :through => :taggings

  scope :selectable, lambda { |motion|
    join = sanitize_sql_array(["left outer join taggings on taggings.tag_id = tags.id and taggings.motion_id = ?", motion])
    select("tags.id, tags.name, taggings.motion_id as not_selectable").
    joins(join).
    order(:name)
  }

  def selectable?
    self.not_selectable.blank?
  end
end

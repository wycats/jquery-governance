class Tag < ActiveRecord::Base
  has_and_belongs_to_many :motions, :join_table => "taggings"

  scope :motion_counts, select("tags.id, tags.name, count(taggings.tag_id) as count").
                      joins("left outer join taggings on taggings.tag_id = tags.id").
                      group("tags.name, taggings.tag_id").
                      order(:name)
end

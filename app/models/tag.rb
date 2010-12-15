class Tag < ActiveRecord::Base
  has_and_belongs_to_many :motions, :join_table => "taggings"
end

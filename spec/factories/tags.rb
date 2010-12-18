FactoryGirl.define do
  factory :tag do
    sequence(:name) {|n| "SwagTag-#{n}"}
  end

  factory :unused_tag, :parent => :tag do
  end

  factory :used_tag, :parent => :tag do
    after_create { |tag| Factory.create(:motion, :tags => [tag]) }
  end
end

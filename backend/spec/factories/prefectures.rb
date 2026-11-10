FactoryBot.define do
  factory :prefecture do
    sequence(:name) { |n| "テスト都道府県#{n}" }
    
  end
end

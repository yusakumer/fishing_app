FactoryBot.define do
  factory :user do
    name {"テスト太郎"}
    sequence(:email) {|n| "test-example#{n}@example.com"}
    password {"password"}
    association :prefecture, factory: :prefecture


  end
end

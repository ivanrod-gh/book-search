FactoryBot.define do
  factory :author do
    sequence :int_id do |n|
      "test_int_id#{n}"
    end
    sequence :name do |n|
      "test_name#{n}"
    end

    trait :named_specific do
      name { 'specific' }
    end
  end
end

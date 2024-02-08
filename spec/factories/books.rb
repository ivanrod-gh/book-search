FactoryBot.define do
  factory :book do
    sequence :int_id do |n|
      "test_int_id#{n}"
    end

    name { 'test_book_name' }
    date { '2000-01-01' }

    trait :frontier do
      int_id { '121281' }
      name { 'Рубеж' }
      date { '2007-07-25' }
    end

    trait :date_added_1987 do
      date { '1987-01-01' }
    end

    trait :date_added_2111 do
      date { '2111-01-01' }
    end

    trait :date_added_2123 do
      date { '2123-01-01' }
    end

    trait :named_specific do
      name { 'specific' }
    end
  end
end

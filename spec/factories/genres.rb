FactoryBot.define do
  factory :genre do
    int_id { 'test_int_id' }
    name { 'test_name' }

    trait :heroic_fantasy do
      int_id { '5075' }
      name { 'Героическая фантастика' }
    end

    trait :books_about_wizards do
      int_id { '5226' }
      name { 'Книги про волшебников' }
    end

    trait :science_fiction do
      int_id { '5073' }
      name { 'Научная фантастика' }
    end

    trait :modern_detectives do
      int_id { '5259' }
      name { 'Современные детективы' }
    end
  end
end

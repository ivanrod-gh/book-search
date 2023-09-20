FactoryBot.define do
  factory :worker_status do
    trait :with_cooldown do
      cooldown_until { Time.zone.now + 10.seconds }
    end

    trait :with_started_at_just_now do
      started_at { Time.zone.now }
    end

    trait :with_pid do
      pid { Process.pid }
    end

    trait :with_reason_403_and_1_try do
      cooldown_reason { '403' }
      try { 1 }
    end
  end
end

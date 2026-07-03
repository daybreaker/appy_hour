FactoryBot.define do
  factory :happy_hour do
    association :venue
    status { :pending }
    notes { nil }
    approved_at { nil }
    submitted_by { nil }
    approved_by { nil }

    trait :approved do
      status { :approved }
      approved_at { Time.current }
      association :approved_by, factory: :user, role: :admin
    end

    trait :pending_deletion do
      status { :pending_deletion }
    end
  end
end

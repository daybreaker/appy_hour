FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :user }

    trait :editor do
      role { :editor }
    end

    trait :admin do
      role { :admin }
    end
  end
end

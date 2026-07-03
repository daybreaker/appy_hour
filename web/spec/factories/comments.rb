FactoryBot.define do
  factory :comment do
    association :user
    body { "Great happy hour, cheap drinks!" }
    status { :approved }
    association :commentable, factory: :venue
  end
end

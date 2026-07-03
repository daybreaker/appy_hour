FactoryBot.define do
  factory :report do
    association :user
    reason { "Happy hour no longer offered" }
    notes { "" }
    resolved_at { nil }
    association :reportable, factory: :happy_hour
  end
end

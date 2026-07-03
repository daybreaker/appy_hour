FactoryBot.define do
  factory :report do
    user { nil }
    reason { "MyString" }
    notes { "MyText" }
    resolved_at { "2026-07-03 10:48:37" }
    reportable { nil }
  end
end

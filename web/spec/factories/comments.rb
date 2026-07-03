FactoryBot.define do
  factory :comment do
    user { nil }
    body { "MyText" }
    status { 1 }
    commentable { nil }
  end
end

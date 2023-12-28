require "faker"
# This will guess the User class
FactoryBot.define do
    factory :item do
        user
        amount { Faker::Number.number(digits: 4) }
        tags_id { [Faker::Number.number(digits: 4)] }
        happened_at { Faker::Date.between(from: 10.days.ago, to: Date.today) }
        kind { 'expenses' }
    end
end

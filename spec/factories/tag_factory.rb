require "faker"
# This will guess the User class
FactoryBot.define do
    factory :tag do
        name { Faker::Lorem.paragraph_by_chars(number: 4) }
        sign { Faker::Lorem.multibyte }
        kind { 'expenses' }
        user
    end
end
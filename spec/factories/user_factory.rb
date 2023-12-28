require "faker"
# This will guess the User class
FactoryBot.define do
    factory :user do
        email { Faker::Internet.email }
    end
end
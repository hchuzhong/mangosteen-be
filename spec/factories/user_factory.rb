require "faker"
# This will guess the User class
FactoryBot.define do
    factory :user do
        email { Faker::Internet.email }
        name { Faker::Lorem.word }
    end
end
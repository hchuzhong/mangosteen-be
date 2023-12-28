require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Me", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "get current user" do
    it "get after sign in successfully" do
      user = User.create email: 'test@qq.com'
      post '/api/v1/session', params: {email: 'test@qq.com', code: '123456'}
      json = JSON.parse response.body
      jwt = json['jwt']
      get '/api/v1/me', headers: {Authorization: "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq user.id
    end
    it "jwt expired" do
      travel_to Time.now - 3.hours
      user1 = create :user
      jwt = user1.generate_jwt
      
      travel_back
      get '/api/v1/me', headers: {Authorization: "Bearer #{jwt}"}
      expect(response).to have_http_status(401)
    end
    it "jwt not expired" do
      travel_to Time.now - 1.hours
      user1 = create :user
      jwt = user1.generate_jwt
      
      travel_back
      get '/api/v1/me', headers: {Authorization: "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
    end
  end
end

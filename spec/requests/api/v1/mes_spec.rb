require 'rails_helper'

RSpec.describe "Me", type: :request do
  describe "get current user" do
    it "get after sign in successfully" do
      user = User.create email: 'hchuzhong@163.com'
      post '/api/v1/session', params: {email: 'hchuzhong@163.com', code: '123456'}
      json = JSON.parse response.body
      jwt = json['jwt']
      
      get '/api/v1/me', headers: {Authorization: "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq user.id
    end
  end
end

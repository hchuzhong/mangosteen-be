require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "session" do
    it "sign in(create session)" do
      User.create email: 'hchuzhong@163.com'
      post '/api/v1/session', params: {email: 'hchuzhong@163.com', code: '123456'}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['jwt']).to be_a(String)
    end
  end
end

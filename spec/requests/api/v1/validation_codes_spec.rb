require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "send validation_codes" do
    it "return 429 with too many requests" do
      post '/api/v1/validation_codes', params: {email: 'test@qq.com'}
      expect(response).to have_http_status(200)
      post '/api/v1/validation_codes', params: {email: 'test@qq.com'}
      expect(response).to have_http_status(429)
    end
    it "return 422 with invalid email" do
      post '/api/v1/validation_codes', params: {email: 'test'}
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['email'][0]).to eq('is invalid')
    end
  end
end

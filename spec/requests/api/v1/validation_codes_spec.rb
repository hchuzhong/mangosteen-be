require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "send validation_codes" do
    it "return 429 with too many requests" do
      post '/api/v1/validation_codes', params: {email: 'test@qq.com'}
      expect(response).to have_http_status(200)
      post '/api/v1/validation_codes', params: {email: 'test@qq.com'}
      expect(response).to have_http_status(429)
    end
  end
end

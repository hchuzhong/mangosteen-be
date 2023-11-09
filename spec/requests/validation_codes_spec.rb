require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "send validation_codes" do
    it "can be sended" do
      post '/api/v1/validation_codes', params: {email: 'hchuzhong@163.com'}
      expect(response).to have_http_status(200)
    end
  end
end

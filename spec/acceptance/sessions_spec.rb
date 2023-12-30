require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Session" do
  post "/api/v1/session" do
    parameter :email, 'Email', required: true
    parameter :code, 'Validation Code', required: true
    response_field :jwt, 'JWT Token for user validation'
    let(:email) { 'test1@qq.com' }
    let(:code) { '123456' }
    example "sign in" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['jwt']).to be_a String
    end
  end
end
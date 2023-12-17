require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Validation Codes" do
    post "/api/v1/validation_codes" do
        parameter :email, type: :string
        let(:email) { 'test@qq.com' }
        example "send validation code request" do
            expect(UserMailer).to receive(:welcome_email).with(email)
            do_request
            expect(status).to eq 200
            expect(response_body).to eq ' '
        end
    end
end
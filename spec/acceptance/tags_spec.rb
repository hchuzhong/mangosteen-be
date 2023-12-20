require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Tags" do
  get "/api/v1/tags" do
    authentication :basic, :auth
    parameter :page, 'Page number'
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "Tag name"
      response_field :sign, "Tag sign"
      response_field :user_id, "User ID"
      response_field :deleted_at, "Deleted time"
    end
    let(:current_user) { User.create email: 'test1@qq.com' }
    let(:auth) { "Bearer #{current_user.generate_jwt}"}
    example "get tag" do
      11.times do Tag.create name: 'x', sign: 'x', user_id: current_user.id end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end
  end
end
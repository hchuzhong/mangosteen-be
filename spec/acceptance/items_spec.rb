require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Items" do
  get "/api/v1/items" do
    parameter :page, 'Page number'
    parameter :created_after, 'Created after(Filter Condition)'
    parameter :created_before, 'Created before(Filter Condition)'
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :amount, "Amount"
    end
    let(:created_after) { '2020-01-01' }
    let(:created_before) { '2020-02-01' }
    example "get data in time range" do
      11.times do Item.create amount: 100, created_at: '2020-01-10' end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end
  end
end
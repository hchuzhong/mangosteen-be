require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Items" do
  let(:current_user) { User.create email: 'test1@qq.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}"}
  get "/api/v1/items" do
    authentication :basic, :auth
    parameter :page, 'Page number'
    parameter :created_after, 'Created after(Filter Condition)'
    parameter :created_before, 'Created before(Filter Condition)'
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :amount, "Amount"
    end
    let(:created_after) { Time.now - 10.days }
    let(:created_before) { Time.now + 10.days }
    example "get data in time range" do
      tag = Tag.create name: 'test', user_id: current_user.id, sign: 'test'
      11.times do Item.create! amount: 100, happened_at: Time.now, tags_id: [tag.id], user_id: current_user.id end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end
  end
  post "/api/v1/items" do
    authentication :basic, :auth
    parameter :amount, "Amount", required: true
    parameter :kind, "Kind", required: true, enum: ['expenses', 'income']
    parameter :happened_at, "Happened At", required: true
    parameter :tags_id, "Tags ID List", required: true
    with_options :scope => :resource do
      response_field :id
      response_field :amount
      response_field :kind
      response_field :happened_at
      response_field :tags_id
    end
    let(:amount) { 100 }
    let(:kind) { 'expenses' }
    let(:happened_at) { Time.now }
    let(:tags) {(0..1).map{ Tag.create name: 'test', user_id: current_user.id, sign: 'x' }}
    let(:tags_id) { tags.map(&:id) }
    example "create item" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['amount']).to eq amount
    end
  end
end
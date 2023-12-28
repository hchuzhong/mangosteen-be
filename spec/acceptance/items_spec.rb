require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Items" do
  let(:current_user) { create :user }
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
  get "/api/v1/items/summary" do
    authentication :basic, :auth
    parameter :happened_after, 'Happened after', required: true
    parameter :happened_before, 'Happened before', required: true
    parameter :kind, 'Kind', enum: ['expenses', 'income'], required: true
    parameter :group_by, 'Group by', enum: ['happened_at', 'tag_id'], required: true
    response_field :group, "Group information"
    response_field :total, "Total amount"
    let(:happened_after) { '2018-11-01' }
    let(:happened_before) { '2018-12-01' }
    let(:kind) { 'expenses' }
    example "get summary information by happened_at" do
      user = current_user
      tag = Tag.create! name: 'test', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tags_id: [tag.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tags_id: [tag.id], happened_at: '2018-11-10T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 400, kind: 'expenses', tags_id: [tag.id], happened_at: '2018-11-10T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 500, kind: 'expenses', tags_id: [tag.id], happened_at: '2018-11-12T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 600, kind: 'expenses', tags_id: [tag.id], happened_at: '2018-11-12T00:00:00.000+08:00', user_id: user.id
      do_request group_by: 'happened_at'
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happened_at']).to eq '2018-11-10'
      expect(json['groups'][0]['amount']).to eq 700
      expect(json['groups'][1]['happened_at']).to eq '2018-11-11'
      expect(json['groups'][1]['amount']).to eq 300
      expect(json['groups'][2]['happened_at']).to eq '2018-11-12'
      expect(json['groups'][2]['amount']).to eq 1100
      expect(json['total']).to eq 2100
    end
    example "get summary information by tag_id" do
      user = current_user
      tag1 = Tag.create name: 'test1', sign: 'x', user_id: user.id
      tag2 = Tag.create name: 'test2', sign: 'x', user_id: user.id
      tag3 = Tag.create name: 'test3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tags_id: [tag1.id, tag2.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tags_id: [tag2.id, tag3.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tags_id: [tag1.id, tag3.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      do_request group_by: 'tag_id'
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['tag_id']).to eq tag3.id
      expect(json['groups'][0]['amount']).to eq 500
      expect(json['groups'][1]['tag_id']).to eq tag1.id
      expect(json['groups'][1]['amount']).to eq 400
      expect(json['groups'][2]['tag_id']).to eq tag2.id
      expect(json['groups'][2]['amount']).to eq 300
      expect(json['total']).to eq 600
    end
  end
end
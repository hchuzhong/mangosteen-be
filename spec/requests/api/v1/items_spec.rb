require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "get accounts" do
    it "pagination when not sign in" do
      user1 = create :user
      get '/api/v1/items'
      expect(response).to have_http_status 401
    end
    it "pagination" do
      user1 = create :user
      user2 = create :user
      create_list :item, 11, amount: 100, user: user1, tag_ids: [create(:tag, user: user1).id]
      create_list :item, 11, amount: 100, user: user2, tag_ids: [create(:tag, user: user2).id]
      # tag1 = Tag.create name: 'tag1', user_id: user1.id, sign: 'x'
      # tag2 = Tag.create name: 'tag1', user_id: user2.id, sign: 'x'
      # 11.times { Item.create amount: 100, happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id }
      # 11.times { Item.create amount: 100, happened_at: Time.now, tag_ids: [tag2.id], user_id: user2.id }

      get '/api/v1/items', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 10
      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end
    it "filter by date" do
      user1 = create :user
      tag1 = Tag.create name: 'tag1', user_id: user1.id, sign: 'x'
      item1 = Item.create amount: 100, created_at: '2018-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2018-01-02', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      item3 = Item.create amount: 100, created_at: '2019-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end
    it "filter by date(boundary condition 0)" do
      user1 = create :user
      tag1 = Tag.create name: 'tag1', user_id: user1.id, sign: 'x'
      item1 = Item.create amount: 100, created_at: '2018-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "filter by date(boundary condition 1)" do
      user1 = create :user
      tag1 = Tag.create name: 'tag1', user_id: user1.id, sign: 'x'
      item1 = Item.create amount: 100, created_at: '2018-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2017-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "filter by date(boundary condition 2)" do
      user1 = create :user
      tag1 = Tag.create name: 'tag1', user_id: user1.id, sign: 'x'
      item1 = Item.create amount: 100, created_at: '2018-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2019-01-01', happened_at: Time.now, tag_ids: [tag1.id], user_id: user1.id
      get '/api/v1/items?created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
  end
  describe "create" do
    it "can't create an item when not sign in" do
      post '/api/v1/items', params: {amount: 99}
      expect(response).to have_http_status 401
    end
    it "can create an item after sign in" do
      user = create :user
      tag1 = Tag.create name: 'test1', sign: 'x', user_id: user.id
      tag2 = Tag.create name: 'test2', sign: 'x', user_id: user.id
      expect {
        post '/api/v1/items', params: {amount: 99, tag_ids: [tag1.id, tag2.id], happened_at: '2018-01-01T00:00:00.000+08:00'}, headers: user.generate_auth_header
      }.to change {Item.count}.by +1
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to be_an(Numeric)
      expect(json['resource']['amount']).to eq 99
      expect(json['resource']['user_id']).to eq user.id
      expect(json['resource']['happened_at']).to eq '2017-12-31T16:00:00.000Z'
    end
    it "can't create an item without required params(amount, tag_ids, happened_at)" do
      user = create :user
      post '/api/v1/items', params: {}, headers: user.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json['errors']['amount'][0]).to eq "can't be blank"
      expect(json['errors']['tag_ids'][0]).to eq "can't be blank"
      expect(json['errors']['happened_at'][0]).to eq "can't be blank"
    end
  end
  describe "get summary" do
    it "group by happened_at" do
      user = create :user
      tag = Tag.create name: 'test', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tag_ids: [tag.id], happened_at: '2018-11-10T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 400, kind: 'expenses', tag_ids: [tag.id], happened_at: '2018-11-10T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 500, kind: 'expenses', tag_ids: [tag.id], happened_at: '2018-11-12T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 600, kind: 'expenses', tag_ids: [tag.id], happened_at: '2018-11-12T00:00:00.000+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        happened_after: '2018-11-01',
        happened_before: '2018-12-01',
        kind: 'expenses',
        group_by: 'happened_at'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happened_at']).to eq '2018-11-10'
      expect(json['groups'][0]['amount']).to eq 700
      expect(json['groups'][1]['happened_at']).to eq '2018-11-11'
      expect(json['groups'][1]['amount']).to eq 300
      expect(json['groups'][2]['happened_at']).to eq '2018-11-12'
      expect(json['groups'][2]['amount']).to eq 1100
      expect(json['total']).to eq 2100
    end
    it "group by tag id" do
      user = create :user
      tag1 = Tag.create name: 'test1', sign: 'x', user_id: user.id
      tag2 = Tag.create name: 'test2', sign: 'x', user_id: user.id
      tag3 = Tag.create name: 'test3', sign: 'x', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag1.id, tag2.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag2.id, tag3.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tag_ids: [tag1.id, tag3.id], happened_at: '2018-11-11T00:00:00.000+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        happened_after: '2018-11-01',
        happened_before: '2018-12-01',
        kind: 'expenses',
        group_by: 'tag_id'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
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

require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "get accounts" do
    it "pagination when not sign in" do
      user1 = User.create email: 'test1@qq.com'
      user2 = User.create email: 'test2@qq.com'
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }
      get '/api/v1/items'
      expect(response).to have_http_status 401
    end
    it "pagination" do
      user1 = User.create email: 'test1@qq.com'
      user2 = User.create email: 'test2@qq.com'
      11.times { Item.create amount: 100, user_id: user1.id }
      11.times { Item.create amount: 100, user_id: user2.id }

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
      user1 = User.create email: 'test1@qq.com'
      item1 = Item.create amount: 100, created_at: '2018-01-02', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2018-01-02', user_id: user1.id
      item3 = Item.create amount: 100, created_at: '2019-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end
    it "filter by date(boundary condition 0)" do
      user1 = User.create email: 'test1@qq.com'
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "filter by date(boundary condition 1)" do
      user1 = User.create email: 'test1@qq.com'
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2017-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end
    it "filter by date(boundary condition 2)" do
      user1 = User.create email: 'test1@qq.com'
      item1 = Item.create amount: 100, created_at: '2018-01-01', user_id: user1.id
      item2 = Item.create amount: 100, created_at: '2019-01-01', user_id: user1.id
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
      user = User.create email: 'test@qq.com'
      tag1 = Tag.create name: 'test1', sign: 'x', user_id: user.id
      tag2 = Tag.create name: 'test2', sign: 'x', user_id: user.id
      expect {
        post '/api/v1/items', params: {amount: 99, tags_id: [tag1.id, tag2.id], happened_at: '2018-01-01T00:00:00.000+08:00'}, headers: user.generate_auth_header
      }.to change {Item.count}.by +1
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to be_an(Numeric)
      expect(json['resource']['amount']).to eq 99
      expect(json['resource']['user_id']).to eq user.id
      expect(json['resource']['happened_at']).to eq '2017-12-31T16:00:00.000Z'
    end
    it "can't create an item without required params(amount, tags_id, happened_at)" do
      user = User.create email: 'test@qq.com'
      post '/api/v1/items', params: {}, headers: user.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json['errors']['amount'][0]).to eq "can't be blank"
      expect(json['errors']['tags_id'][0]).to eq "can't be blank"
      expect(json['errors']['happened_at'][0]).to eq "can't be blank"
    end
  end
end

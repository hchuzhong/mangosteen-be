require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  describe "GET /index" do
    it "get tags before sign in" do
      get '/api/v1/tags'
      expect(response).to have_http_status(401)
    end
    it "get tags after sign in" do
      user = User.create email: 'test@qq.com'
      another_user = User.create email: 'test1@qq.com'
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x' end
      11.times do |i| Tag.create name: "tag#{i}", user_id: another_user.id, sign: 'x' end

      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 10

      get '/api/v1/tags', headers: user.generate_auth_header, params: { page: 2 }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
    it "get tags by kind" do
      user = User.create email: 'test@qq.com'
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x', kind: 'expenses' end
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x', kind: 'income' end
      
      get '/api/v1/tags', headers: user.generate_auth_header, params: { kind: 'expenses' }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 10

      get '/api/v1/tags', headers: user.generate_auth_header, params: {  kind: 'expenses', page: 2 }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
  end
  describe "GET /show" do
    it "get single tag before sign in" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "get single tag after sign in" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq tag.id
    end
    it "get other user's tag" do
      user = User.create email: 'test@qq.com'
      other = User.create email: 'test1@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: other.id
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
  describe "POST /create" do
    it "create tag before sign in" do
      post '/api/v1/tags', params: { name: 'test', sign: 'sign' }
      expect(response).to have_http_status(401)
    end
    it "create tag after sign in" do
      user = User.create email: 'test@qq.com'
      post '/api/v1/tags', params: { name: 'test', sign: 'sign' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'test'
      expect(json['resource']['sign']).to eq 'sign'
    end
    it "create tag after sign in failed, because the name was not filled in" do
      user = User.create email: 'test@qq.com'
      post '/api/v1/tags', params: { sign: 'x' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['name'][0]).to eq "can't be blank"
    end
    it "create tag after sign in failed, because the sign was not filled in" do
      user = User.create email: 'test@qq.com'
      post '/api/v1/tags', params: { name: 'x' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['sign'][0]).to eq "can't be blank"
    end
  end
  describe "Update /patch" do
    it "update tag before sign in" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'test1', sign: 'sign1' }
      expect(response).to have_http_status(401)
    end
    it "update tag after sign in" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'test1', sign: 'sign1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'test1'
      expect(json['resource']['sign']).to eq 'sign1'
    end
    it "only update tag's sign" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { sign: 'sign1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'test'
      expect(json['resource']['sign']).to eq 'sign1'
    end
    it "only update tag's name" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'test1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'test1'
      expect(json['resource']['sign']).to eq 'sign'
    end
    it "update other user's tag" do
      user = User.create email: 'test@qq.com'
      other = User.create email: 'other@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: other.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'test1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
  describe "Destroy /delete" do
    it "delete tag before sign in" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "delete tag after sign in" do
      user = User.create email: 'test@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: user.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it "delete other user's tag" do
      user = User.create email: 'test@qq.com'
      other = User.create email: 'other@qq.com'
      tag = Tag.create name: 'test', sign: 'sign', user_id: other.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
end

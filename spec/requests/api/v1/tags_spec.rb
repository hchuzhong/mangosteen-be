require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  describe "GET /index" do
    it "get tags before sign in" do
      get '/api/v1/tags'
      expect(response).to have_http_status(401)
    end
    it "get tags after sign in" do
      user = create :user
      another_user = create :user
      create_list :tag, Tag.default_per_page + 1, user: user
      create_list :tag, Tag.default_per_page + 1, user: another_user

      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq Tag.default_per_page

      get '/api/v1/tags', headers: user.generate_auth_header, params: { page: 2 }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
    it "get tags by kind" do
      user = create :user
      create_list :tag, Tag.default_per_page + 1, user: user, kind: 'expenses'
      create_list :tag, Tag.default_per_page + 1, user: user, kind: 'income'
      
      get '/api/v1/tags', headers: user.generate_auth_header, params: { kind: 'expenses' }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq Tag.default_per_page

      get '/api/v1/tags', headers: user.generate_auth_header, params: {  kind: 'expenses', page: 2 }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resources'].size).to eq 1
    end
  end
  describe "GET /show" do
    it "get single tag before sign in" do
      user = create :user
      tag = create :tag, user: user
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "get single tag after sign in" do
      user = create :user
      tag = create :tag, user: user
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq tag.id
    end
    it "get other user's tag" do
      user = create :user
      other = create :user
      tag = create :tag, user_id: other.id
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
      user = create :user
      post '/api/v1/tags', params: { name: 'test', sign: 'sign', kind: 'expenses' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 'test'
      expect(json['resource']['sign']).to eq 'sign'
    end
    it "create tag after sign in failed, because the name was not filled in" do
      user = create :user
      post '/api/v1/tags', params: { sign: 'x', kind: 'expenses' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['name'][0]).to eq "can't be blank"
    end
    it "create tag after sign in failed, because the sign was not filled in" do
      user = create :user
      post '/api/v1/tags', params: { name: 'x', kind: 'expenses' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['sign'][0]).to eq "can't be blank"
    end
    it "create tag after sign in failed, because the kind was not filled in" do
      user = create :user
      post '/api/v1/tags', params: { name: 'x', sign: 'x' }, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['kind'][0]).to eq "can't be blank"
    end
  end
  describe "Update /patch" do
    it "update tag before sign in" do
      user = create :user
      tag = create :tag, user: user
      patch "/api/v1/tags/#{tag.id}", params: { name: 't1', sign: 'sign1' }
      expect(response).to have_http_status(401)
    end
    it "update tag after sign in" do
      user = create :user
      tag = create :tag, user: user
      patch "/api/v1/tags/#{tag.id}", params: { name: 't1', sign: 'sign1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 't1'
      expect(json['resource']['sign']).to eq 'sign1'
    end
    it "only update tag's sign" do
      user = create :user
      tag = create :tag, user: user
      patch "/api/v1/tags/#{tag.id}", params: { sign: 'sign1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq tag.name
      expect(json['resource']['sign']).to eq 'sign1'
    end
    it "only update tag's name" do
      user = create :user
      tag = create :tag, user: user
      patch "/api/v1/tags/#{tag.id}", params: { name: 't1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['resource']['name']).to eq 't1'
      expect(json['resource']['sign']).to eq  tag.sign
    end
    it "update other user's tag" do
      user = create :user
      other = create :user
      tag = create :tag, user_id: other.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'test1' }, headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
  describe "Destroy /delete" do
    it "delete tag before sign in" do
      user = create :user
      tag = create :tag, user: user
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "delete tag after sign in" do
      user = create :user
      tag = create :tag, user: user
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it "delete other user's tag" do
      user = create :user
      other = create :user
      tag = create :tag, user_id: other.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(403)
    end
    it "delete tag and items which used it" do
      user = create :user
      tag = create :tag, user: user
      items = create_list :item, 2, user: user, tag_ids: [tag.id]
      delete "/api/v1/tags/#{tag.id}?with_items=true", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      items.first.reload
      items.second.reload
      expect(tag.deleted_at).not_to eq nil
      expect(items.first.deleted_at).not_to eq nil
      expect(items.second.deleted_at).not_to eq nil      
    end
  end
end

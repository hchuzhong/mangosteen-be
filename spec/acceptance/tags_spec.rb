require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Tags" do
  authentication :basic, :auth
  let(:current_user) { create :user }
  let(:auth) { "Bearer #{current_user.generate_jwt}"}
  get "/api/v1/tags/:id" do
    let (:tag) { create :tag, user: current_user }
    let (:id) { tag.id }
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "Tag name"
      response_field :sign, "Tag sign"
      response_field :user_id, "User ID"
      response_field :deleted_at, "Deleted time"
    end
    example "get tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['id']).to eq tag.id
    end
  end
  get "/api/v1/tags" do
    parameter :page, 'Page number'
    parameter :kind, 'Tag kind', enum: ['expenses', 'income']
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "Tag name"
      response_field :sign, "Tag sign"
      response_field :user_id, "User ID"
      response_field :deleted_at, "Deleted time"
    end
    example "get tag list" do
      create_list :tag, Tag.default_per_page + 1, user: current_user
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq Tag.default_per_page
    end
  end
  post "/api/v1/tags" do
    parameter :name, 'Tag name', required: true
    parameter :sign, 'Tag sign', required: true
    parameter :kind, 'Tag kind', required: true, enum: ['expenses', 'income']
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "Tag name"
      response_field :sign, "Tag sign"
      response_field :user_id, "User ID"
      response_field :deleted_at, "Deleted time"
    end
    let (:name) { 'name' }
    let (:sign) { 'test sign' }
    let (:kind) { 'expenses' }
    example "create tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  patch "/api/v1/tags/:id" do
    let (:tag) { create :tag, user: current_user }
    let (:id) { tag.id }
    parameter :name, 'Tag name'
    parameter :sign, 'Tag sign'
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "Tag name"
      response_field :sign, "Tag sign"
      response_field :user_id, "User ID"
      response_field :deleted_at, "Deleted time"
    end
    let (:name) { 'name' }
    let (:sign) { 'test sign' }
    example "update tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  delete "/api/v1/tags/:id" do
    let (:tag) { create :tag, user: current_user }
    let (:id) { tag.id }
    let (:with_items) { 'true' }
    parameter :with_items, 'delete items or not', enum: ['true', 'false']
    example "delete tag" do
      do_request
      expect(status).to eq 200
    end
  end
end
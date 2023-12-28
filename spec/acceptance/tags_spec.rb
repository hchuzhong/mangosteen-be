require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Tags" do
  authentication :basic, :auth
  let(:current_user) { create :user }
  let(:auth) { "Bearer #{current_user.generate_jwt}"}
  get "/api/v1/tags/:id" do
    let (:tag) { Tag.create name: 'Tag name', sign: 'Tag sign', user_id: current_user.id }
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
      11.times do Tag.create name: 'x', sign: 'x', user_id: current_user.id end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end
  end
  post "/api/v1/tags" do
    parameter :name, 'Tag name', required: true
    parameter :sign, 'Tag sign', required: true
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :name, "Tag name"
      response_field :sign, "Tag sign"
      response_field :user_id, "User ID"
      response_field :deleted_at, "Deleted time"
    end
    let (:name) { 'test name' }
    let (:sign) { 'test sign' }
    example "create tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end
  end
  patch "/api/v1/tags/:id" do
    let (:tag) { Tag.create name: 'Tag name', sign: 'Tag sign', user_id: current_user.id }
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
    let (:name) { 'test name' }
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
    let (:tag) { Tag.create name: 'Tag name', sign: 'Tag sign', user_id: current_user.id }
    let (:id) { tag.id }
    example "delete tag" do
      do_request
      expect(status).to eq 200
    end
  end
end
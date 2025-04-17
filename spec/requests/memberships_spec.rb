require 'rails_helper'

RSpec.describe "Memberships", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/memberships/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/memberships/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/memberships/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end

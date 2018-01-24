require 'rails_helper'

RSpec.describe "Admin::Websites", type: :request do
  describe "GET /admin_websites" do
    it "works! (now write some real specs)" do
      get admin_websites_path
      expect(response).to have_http_status(200)
    end
  end
end

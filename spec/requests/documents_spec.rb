require 'spec_helper'

RSpec.describe "Documents", type: :request do
  describe "GET /documents" do
    it "works! (now write some real specs)" do
      skip
      get documents_path
      expect(response).to have_http_status(200)
    end
  end
end

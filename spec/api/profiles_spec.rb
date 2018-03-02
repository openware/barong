require 'spec_helper'

let(:profile) { create :profile }

describe 'Profiles API'
  describe "GET #index" do
      it "returns a success response" do
        get :index
        expect(response).to be_success
      end
    end

    describe "GET #show" do
      it "returns a success response" do
        get :show
        expect(response).to be_success
      end
    end
  end

require "spec_helper"

RSpec.describe CustomersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/customers").to route_to("customers#index")
    end

    it "routes to #new" do
      expect(:get => "/customers/new").to route_to("customers#new")
    end

    it "routes to #show" do
      expect(:get => "/customers/1").to route_to("customers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/customers/1/edit").to route_to("customers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/customers").to route_to("customers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/customers/1").to route_to("customers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/customers/1").to route_to("customers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/customers/1").to route_to("customers#destroy", :id => "1")
    end

  end
end

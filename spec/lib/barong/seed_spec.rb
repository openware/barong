# frozen_string_literal: true

require_dependency 'barong/seed'

describe Barong::Seed do
  let(:levels) {[]}
  let(:users) {[]}
  let(:seeds) {
    {
      "users" => users,
      "levels" => levels   
    }
  }

  let(:logger) { Logger.new('/dev/null') }
  let(:seeder) { Barong::Seed.new }

  before(:each) do
    allow(seeder).to receive(:seeds).and_return(seeds)
    allow(seeder).to receive(:logger).and_return(logger)
    Level.delete_all
    User.delete_all
  end

  context "Seed simple and valid levels" do
    let(:levels) {
      [
        {
          "key" => "email",
          "value" => "verified",
          "description" => "User clicked on the confirmation link"
        },
        {
          "key" => "phone",
          "value" => "verified",
          "description" => "User entered a valid code from sms"
        }
      ]
    }

    it "seeds levels in database" do
      seeder.seed_levels
      expect(Level.count).to be 2
      Level.all.each_with_index do |level, index|
        expect(level.key).to eq levels[index]["key"]
        expect(level.value).to eq levels[index]["value"]
        expect(level.description).to eq levels[index]["description"]
      end
    end
  end

  context "Seed one admin user" do
    let(:users) {
      [
        {
          "email" => "admin@peatio.tech",
          "password" => "123aZE@654",
          "role" => "admin",
          "state" => "active",
          "level" => 3
        }
      ]
    }


    it "seeds users in database" do
      seeder.seed_users
      expect(User.count).to eq 1
      user = User.first
      expect(user.email).to eq("admin@peatio.tech")
      expect(user.role).to eq("admin")
      expect(user.state).to eq("active")
      expect(user.level).to eq(3)
    end
  end
end

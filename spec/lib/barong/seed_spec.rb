# frozen_string_literal: true

require_dependency 'barong/seed'

describe "Default seeds.yml template" do
  let(:seeds) { Barong::Seed.new.seeds }

  it "Generate seed using environement variables" do
    expect(ENV).to receive(:fetch).with(any_args).and_call_original
    expect(ENV).to receive(:fetch).with("ADMIN_EMAIL", "admin@barong.io").and_call_original
    expect(ENV).to receive(:fetch).with("ADMIN_PASSWORD", nil).and_return("123AZErty@")
    expect(seeds["users"]).to eq([
                                   {
                                     "email" => "admin@barong.io",
                                     "password" => "123AZErty@",
                                     "role" => "admin",
                                     "state" => "active",
                                     "level" => 3
                                   }
                                 ])
    expect(seeds["levels"].size).to eq(3)
  end
end

describe Barong::Seed do
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
    it "seeds levels in database" do
      seeder.seed_levels
      expect(Level.count).to be 2
      Level.all.each_with_index do |level, index|
        expect(level.id).to eq (index+1)
        expect(level.key).to eq levels[index]["key"]
        expect(level.value).to eq levels[index]["value"]
        expect(level.description).to eq levels[index]["description"]
      end
    end

    it "skips existing levels" do
      seeder.seed_levels
      seeder.seed_levels
      expect(Level.count).to be 2
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
          "level" => 2
        }
      ]
    }

    it "seeds users in database" do
      seeder.seed_levels
      seeder.seed_users
      expect(User.count).to eq 1
      user = User.first
      expect(user.email).to eq("admin@peatio.tech")
      expect(user.role).to eq("admin")
      expect(user.state).to eq("active")
      expect(user.level).to eq(2)
    end
  end

  context "User level doesn't match levels in databases" do
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

    it "raises an explicit error" do
      seeder.seed_levels
      expect {
        seeder.seed_users
      }.to raise_error(Barong::Seed::ConfigError, "No enough levels found in database to grant the user to level 3")
    end
  end

  context "User level is not set" do
    let(:users) {
      [
        {
          "email" => "admin@peatio.tech",
          "password" => "123aZE@654",
          "role" => "admin",
          "state" => "active",
        }
      ]
    }

    it "raises an explicit error" do
      seeder.seed_levels
      expect {
        seeder.seed_users
      }.to raise_error(Barong::Seed::ConfigError, "Level is missing for user admin@peatio.tech")
    end
  end

  context "User email is not set" do
    let(:users) {
      [
        {
          "password" => "123aZE@654",
          "role" => "admin",
          "state" => "active",
          "level" => 2
        }
      ]
    }

    it "raises an explicit error" do
      seeder.seed_levels
      expect {
        seeder.seed_users
      }.to raise_error(Barong::Seed::ConfigError, "Email missing in users seed")
    end
  end

  context "User state is not set" do
    let(:users) {
      [
        {
          "email" => "admin@peatio.tech",
          "password" => "123aZE@654",
          "role" => "admin",
          "level" => 2
        }
      ]
    }

    it "defaults state to pending" do
      seeder.seed_levels
      seeder.seed_users
      expect(User.count).to eq 1
      user = User.first
      expect(user.email).to eq("admin@peatio.tech")
      expect(user.role).to eq("admin")
      expect(user.state).to eq("pending")
      expect(user.level).to eq(2)
    end
  end

  context "User role is not set" do
    let(:users) {
      [
        {
          "email" => "admin@peatio.tech",
          "password" => "123aZE@654",
          "state" => "active",
          "level" => 2
        }
      ]
    }

    it "defaults role to member" do
      seeder.seed_levels
      seeder.seed_users
      expect(User.count).to eq 1
      user = User.first
      expect(user.email).to eq("admin@peatio.tech")
      expect(user.role).to eq("member")
      expect(user.state).to eq("active")
      expect(user.level).to eq(2)
    end
  end

  context "Seed one admin and a regular user" do
    let(:users) {
      [
        {
          "email" => "admin@peatio.tech",
          "password" => "123aZE@654",
          "role" => "admin",
          "state" => "active",
          "level" => 2
        },
        {
          "email" => "user@example.com",
          "password" => "123aZE@654",
          "role" => "member",
          "state" => "active",
          "level" => 2
        }
      ]
    }

    it "seeds users in database" do
      seeder.seed_levels
      seeder.seed_users

      expect(User.count).to eq 2

      admin = User.find_by(email: "admin@peatio.tech")
      expect(admin.role).to eq("admin")
      expect(admin.state).to eq("active")
      expect(admin.level).to eq(2)

      admin = User.find_by(email: "user@example.com")
      expect(admin.role).to eq("member")
      expect(admin.state).to eq("active")
      expect(admin.level).to eq(2)
    end
  end
end

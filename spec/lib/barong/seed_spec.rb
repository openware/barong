# frozen_string_literal: true

require_dependency 'barong/seed'

describe "Default seeds.yml template" do
  let(:seeds) { Barong::Seed.new.seeds }

  it "Generate seed using environement variables" do
    expect(ENV).to receive(:fetch).with("BARONG_ADMIN_EMAIL", "admin@barong.io").and_call_original
    expect(ENV).to receive(:fetch).with("BARONG_ADMIN_PASSWORD", nil).and_return("123AZErty@")
    expect(seeds["levels"].size).to eq(3)
  end
end

describe Barong::Seed do
  let(:create_permissions) do
    create :permission,
           role: 'member'
    create :permission,
           role: 'admin'
  end
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
  let(:permissions) {[]}
  let(:restrictions) {[]}
  let(:users) {[]}
  let(:seeds) {
    {
      "users" => users,
      "levels" => levels,
      "permissions" => permissions,
      "restrictions" => restrictions
    }
  }

  let(:logger) { Logger.new('/dev/null') }
  let(:seeder) { Barong::Seed.new }

  before(:each) do
    allow(seeder).to receive(:seeds).and_return(seeds)
    allow(seeder).to receive(:logger).and_return(logger)
    Level.delete_all
    User.delete_all
    Permission.delete_all
    Restriction.delete_all
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
      create_permissions
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
      create_permissions
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
          "level" => 0
        }
      ]
    }

    it "defaults state to pending" do
      create_permissions
      seeder.seed_levels
      seeder.seed_users
      expect(User.count).to eq 1
      user = User.first
      expect(user.email).to eq("admin@peatio.tech")
      expect(user.role).to eq("admin")
      expect(user.state).to eq("pending")
      expect(user.level).to eq(0)
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
      create_permissions
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
      create_permissions
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

  context "Seed simple GET /me member permissions" do
    let(:permissions) {
      [
        {
          "role" => "member",
          "verb" => "GET",
          "action" => "ACCEPT",
          "path" => "api/v2/resource/users/me"
        }
      ]
    }

    it "seeds permissions in database" do
      seeder.seed_permissions
      expect(Permission.count).to eq 1
      permission = Permission.first
      expect(permission.role).to eq("member")
      expect(permission.verb).to eq("GET")
      expect(permission.path).to eq("api/v2/resource/users/me")
    end
  end

  context "Permission verb is not set" do
    let(:permissions) {
      [
        {
          "role" => "member",
          "action" => "ACCEPT",
          "path" => "api/v2/resource/users/me"
        }
      ]
    }

    it "raises an explicit error" do
      expect {
        seeder.seed_permissions
      }.to raise_error(Barong::Seed::ConfigError, "Can't create permission: Verb can't be blank")
    end
  end

  context "Permission path is not set" do
    let(:permissions) {
      [
        {
          "role" => "member",
          "action" => "ACCEPT",
          "verb" => "GET"
        }
      ]
    }
    it "raises an explicit error" do
      expect {
        seeder.seed_permissions
      }.to raise_error(Barong::Seed::ConfigError, "Can't create permission: Path can't be blank")
    end
  end

  context "Seed one admin GET and one accountant POST permissions" do
    let(:permissions) {
      [
        {
          "role" => "admin",
          "verb" => "GET",
          "action" => "ACCEPT",
          "path" => "api/v2/admin/users/list"
        },
        {
          "role" => "accountant",
          "verb" => "POST",
          "action" => "ACCEPT",
          "path" => "api/v2/admin/users"
        }
      ]
    }

    it "seeds permissions in database" do
      seeder.seed_permissions
      expect(Permission.count).to eq 2

      admin_permission = Permission.find_by_role('admin')
      expect(admin_permission.role).to eq("admin")
      expect(admin_permission.verb).to eq("GET")
      expect(admin_permission.path).to eq("api/v2/admin/users/list")

      accountant_permission = Permission.find_by_role('accountant')
      expect(accountant_permission.role).to eq("accountant")
      expect(accountant_permission.verb).to eq("POST")
      expect(accountant_permission.path).to eq("api/v2/admin/users")
    end
  end

  context "Seed simple and valid restrictions" do
    let(:restrictions) {
      [
        {
          "category" => "maintenance",
          "scope" => "all",
          "value" => "all",
          "state" => "enabled"
        },
        {
          "category" => "blacklist",
          "scope" => "all",
          "value" => "all",
          "state" => "enabled"
        }
      ]
    }

    it "seeds restrictions in database" do
      seeder.seed_restrictions
      expect(Restriction.count).to be 2
      Restriction.all.each_with_index do |restriction, index|
        expect(restriction.category).to eq restrictions[index]["category"]
        expect(restriction.scope).to eq restrictions[index]["value"]
        expect(restriction.value).to eq restrictions[index]["value"]
        expect(restriction.state).to eq restrictions[index]["state"]
      end
    end
  end

  context "Empty seed" do
    it "returns without error and with kind log info" do
      expect {
        seeder.seed_restrictions
      }.not_to raise_error
    end
  end

  context "Missing params in restriction seed" do
    let(:restrictions) {
      [
        {
          "category" => "maintenance",
          "scope" => "all",
          "value" => "all",
        }
      ]
    }

    it "raises error on invalid seed" do
      expect {
        seeder.seed_restrictions
      }.to raise_error(Barong::Seed::ConfigError, "state is missing in restrictions seed")
    end
  end
end

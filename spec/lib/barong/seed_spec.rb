# frozen_string_literal: true

require_dependency 'barong/seed'

describe Barong::Seed do
  let(:levels) {
    [
      {"key" => "email",
       "value" => "verified",
       "description" => "User clicked on the confirmation link"},
      {"key" => "phone",
       "value" => "verified",
       "description" => "User entered a valid code from sms"},
      {"key" => "document",
       "value" => "verified",
       "description" => "User personal documents have been verified"}
    ]
  }

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

  let(:seeder) { Barong::Seed.new }

  it "seeds levels in database" do
    Level.delete_all
    seeder.seed_levels
    Level.all.each_with_index do |level, index|
      expect(level.key).to eq levels[index]["key"]
      expect(level.value).to eq levels[index]["value"]
      expect(level.description).to eq levels[index]["description"]
    end
  end

  it "seeds users in database" do
    seeder.seed_users
  end
end

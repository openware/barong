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

  let(:seeds) {
    {
      "users" => users,
      "levels" => levels   
    }
  }

  it "seeds levels in database" do
    fail
  end

  it "seeds users in database" do
    fail
  end
end

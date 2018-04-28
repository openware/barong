# frozen_string_literal: true

def json_body
  JSON.parse(response.body, symbolize_names: true)
end

def expect_status_to_eq(status)
  expect_status.to eq status
end

def expect_status
  expect(response.status)
end

def expect_body
  expect(json_body)
end

def create_label_with_level(account, level, scope: 'private')
  create(:label, account: account,
                 key: level.key,
                 value: level.value,
                 scope: scope)
end

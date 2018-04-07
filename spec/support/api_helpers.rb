# frozen_string_literal: true

def json_body
  JSON.parse(response.body, symbolize_names: true)
end

def expect_status_to_eq(status)
  expect(response.status).to eq status
end

def expect_body
  expect(json_body)
end

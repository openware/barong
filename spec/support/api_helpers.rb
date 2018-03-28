def json_body
  JSON.parse(response.body)
end

def expect_status_to_eq(status)
  expect(response.status).to eq status
end

def expect_body
  expect(json_body)
end

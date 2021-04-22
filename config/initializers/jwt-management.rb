def generate_jwt_management(data)
  JWT::Multisig.generate_jwt(
    {
      exp:  Time.now.to_i + 60,
      data: data
    },
    {
      :applogic => Barong::App.config.keystore.private_key
    },
    {
      :applogic => "RS256"
    }
  ).to_json
end

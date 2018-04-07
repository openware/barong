# frozen_string_literal: true

class FakeSMS

  cattr_accessor :messages
  self.messages = []

  def initialize(_account_sid, _auth_token)
  end

  def messages
    self
  end

  def create(params)
    self.class.messages << OpenStruct.new(params)
  end
end

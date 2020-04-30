# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id           :bigint           not null, primary key
#  user_id      :integer          unsigned, not null
#  country      :string(255)      not null
#  number       :string(255)      not null
#  code         :string(5)
#  validated_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#


FactoryBot.define do
    factory :phone do
      number { '12345678911' }
      user
    end
  end

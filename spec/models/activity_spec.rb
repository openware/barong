# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  context 'User model basic syntax' do
    it { should belong_to(:user) }
  end

  describe 'Validations' do
    context '#category' do
      it { should_not allow_value('random_category').for(:category)}
      it { should allow_value('session').for(:category)}
      it { should allow_value('otp').for(:category)}
      it { should allow_value('password').for(:category)}
    end

    context '#result' do
      it { should_not allow_value('passed').for(:result) }
      it { should allow_value('succeed').for(:result) }
      it { should allow_value('failed').for(:result) }
    end
  end
end

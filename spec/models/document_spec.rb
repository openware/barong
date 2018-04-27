# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Document, type: :model do
  ## Test of relationships
  it { should belong_to(:account) }

  describe 'upload new document for rejected profile' do
    let(:profile) { create :profile, state: 'rejected' }

    it 'changes rejected profile state' do
      expect(profile.state).to eq('rejected')
      create :document, account: profile.account
      expect(profile.state).to eq('pending')
    end

    it 'does not change pending profile state' do
      create :document, account: profile.account
      expect(profile.state).to eq('pending')
    end

    it 'does not change approved profile state' do
      profile.update(state: 'approved')
      create :document, account: profile.account
      expect(profile.state).to eq('approved')
    end
  end
end

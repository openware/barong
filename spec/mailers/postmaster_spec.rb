# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Postmaster, type: :mailer do
  let!(:create_admin_permission) do
    create :permission,
           role: 'admin'
  end
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  describe '#process_payload' do
    let!(:user) { create(:user, email: 'test1@gmail.com') }
    let(:record) { OpenStruct.new(domain: 'barong.com', token: 'blah-blah' ) }
    let(:payload) do
      {
        user: user,
        changes: nil,
        record: record,
        subject: 'Test Email',
        template_name: 'email_confirmation.en.html.erb',
        logo: 'https://storage.googleapis.com/public_peatio/logo.png'
      }
    end
    let(:mail) { Postmaster.process_payload(payload) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Test Email')
      expect(mail.to).to eq(['test1@gmail.com'])
      expect(mail.from).to eq(['noreply@barong.io'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Use this unique link to confirm your email test1@gmail.com')
    end
  end
end

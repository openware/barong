# frozen_string_literal: true

describe 'accounts management', order: :defined do
  let!(:admin) { create :admin }
  let!(:member) { create :account }

  before(:example) do
    sign_in admin
    visit admin_accounts_path
  end

  def row_for(account)
    within '.container table' do
      find('tr') { |el| el.has_text?(account.email) }
    end
  end

  context 'on admin panel' do
    it 'can set account role' do
      within row_for(member) do
        click_on 'Edit'
      end

      select 'admin', from: 'account_role'
      click_on 'Submit'

      expect(row_for(member).find('.badge')).to have_text 'admin'
    end

    it 'can delete accounts' do
      within row_for(member) do
        click_on 'Delete'
      end

      within 'div.modal' do
        click_button 'Confirm'
      end

      visit admin_accounts_path

      expect(page).not_to have_content(member.email)
    end
  end
end

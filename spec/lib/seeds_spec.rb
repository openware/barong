# frozen_string_literal: true

describe 'Seeds task' do
  before do
    Barong::Application.load_tasks
    allow(YAML).to receive(:safe_load) { seeds }
    allow(Logger).to receive(:new) { double(info: '', error: '') }
  end
  around do |example|
    original_stdout = $stdout
    $stdout = File.new('/dev/null', 'w')
    example.run
    $stdout = original_stdout
  end
  let(:account_attributes) do
    {
      'email' => 'admin@barong.io',
      'role' => 'admin',
      'state' => 'active'
    }
  end
  let(:seeds) do
    {
      'accounts' => [
        'account' => account_attributes
      ],
      'applications' => [
        {
          'name' => 'Peatio',
          'redirect_uri' => 'https://peatio:8000/auth/barong/callback',
          'skipauth' => true
        }
      ],
      'levels' => [
        {
          'key' => 'key',
          'value' => 'verified',
          'description' => 'User clicked on the confirmation link'
        }
      ]
    }
  end
  let(:command) { Rake::Task['db:seed'].execute }

  context 'accounts' do
    it 'creates an account' do
      expect { command }.to change { Account.count }.by(1)
      account = Account.find_by(account_attributes)
      expect(account).to be
      expect(account.confirmed_at).to be
      expect(account.level).to eq 1
      expect(account.labels.find_by(key: 'email',
                                    value: 'verified',
                                    scope: 'private')).to be
    end

    it 'does not duplicate account' do
      command
      expect { command }.to_not change { Account.count }
    end
  end

  context 'applications' do
    it 'creates an application' do
      expect { command }.to change { Doorkeeper::Application.count }.by(1)
      expect(Doorkeeper::Application.find_by(name: 'Peatio')).to be
    end

    it 'does not duplicate application' do
      command
      expect { command }.to_not change { Doorkeeper::Application.count }
    end
  end

  context 'levels' do
    it 'creates a level' do
      expect { command }.to change { Level.count }.by(1)
      expect(Level.find_by(key: 'key',
                           value: 'verified')).to be
    end

    it 'does not duplicate level' do
      command
      expect { command }.to_not change { Level.count }
    end
  end
end

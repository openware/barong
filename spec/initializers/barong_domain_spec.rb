# frozen_string_literal: true

describe 'BARONG_DOMAIN start without http/https' do
  before { allow(Barong::App.config).to receive(:domain).and_return('openware.com') }

  context 'when BARONG_TLS_ENABLED is true' do
    before { allow(Barong::App.config).to receive(:tls_enabled).and_return(true) }

    it 'use https' do
      expect(Barong::App.url).to eq('https://openware.com')
    end
  end

  context 'when BARONG_TLS_ENABLED is false' do
    before { allow(Barong::App.config).to receive(:tls_enabled).and_return(false) }

    it 'use http' do
      expect(Barong::App.url).to eq('http://openware.com')
    end
  end
end

describe 'BARONG_DOMAIN start with http' do
  before { allow(Barong::App.config).to receive(:domain).and_return('http://openware.com') }

  context 'when BARONG_TLS_ENABLED is true' do
    before { allow(Barong::App.config).to receive(:tls_enabled).and_return(true) }

    it 'use http' do
      expect(Barong::App.url).to eq('http://openware.com')
    end
  end

  context 'when BARONG_TLS_ENABLED is false' do
    before { allow(Barong::App.config).to receive(:tls_enabled).and_return(false) }

    it 'use http' do
      expect(Barong::App.url).to eq('http://openware.com')
    end
  end
end

describe 'BARONG_DOMAIN start with https' do
  before { allow(Barong::App.config).to receive(:domain).and_return('https://openware.com') }

  context 'when BARONG_TLS_ENABLED is true' do
    before { allow(Barong::App.config).to receive(:tls_enabled).and_return(true) }

    it 'use https' do
      expect(Barong::App.url).to eq('https://openware.com')
    end
  end

  context 'when BARONG_TLS_ENABLED is false' do
    before { allow(Barong::App.config).to receive(:tls_enabled).and_return(false) }

    it 'use https' do
      expect(Barong::App.url).to eq('https://openware.com')
    end
  end
end

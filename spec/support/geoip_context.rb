# frozen_string_literal: true

shared_context 'geoip mock' do
  let(:london_ip) { '196.245.163.202' }
  let(:tokyo_ip) { '140.227.60.114' }

  before do
    class DummyReader
      def get(ip)
        case ip
        when '196.245.163.202'
          {
            'country' => { 'names' => { 'en' => 'United Kingdom' } },
            'continent' => { 'names' => { 'en' => 'Europe' } }
          }
        when '140.227.60.114'
          {
            'country' => { 'names' => { 'en' => 'Japan' } },
            'continent' => { 'names' => { 'en' => 'Asia' } }
          }
        else
          {}
        end
      end
    end

    reader = DummyReader.new

    allow(Barong::GeoIP).to receive(:reader).and_return(reader)
  end
end

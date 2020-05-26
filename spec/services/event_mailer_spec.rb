# frozen_string_literal: true

describe EventMailer do
  let(:event_mailer) { EventMailer.new('', '', '')}
  let(:event) {
    {:record=>
      {:user=>
        {:uid=>"ID8434CD6E8E",
         :email=>"admin@barong.io",
         :role=>"admin",
         :level=>1,
         :otp=>false,
         :state=>"active",
         :referral_uid=>nil,
         :created_at=>"2020-05-26T07:01:04Z",
         :updated_at=>"2020-05-26T08:30:54Z"},
       :user_ip=>"::1",
       :user_agent=>"PostmanRuntime/7.25.0"},
     :name=>"system.session.create",
     :state=>"sdasd"
    }
  }

  describe "#nested_hash_value" do
    it 'return event value' do
      expect(event_mailer.send(:safe_dig, event, %i[name])).to eq event[:name]
      expect(event_mailer.send(:safe_dig, event, %i[record user state])).to eq event[:record][:user][:state]
      expect(event_mailer.send(:safe_dig, event, %i[record user uid])).to eq event[:record][:user][:uid]
      expect(event_mailer.send(:safe_dig, event, %i[record user_agent])).to eq event[:record][:user_agent]
      expect(event_mailer.send(:safe_dig, event, %i[record user_ip])).to eq event[:record][:user_ip]
      expect(event_mailer.send(:safe_dig, event, %i[record name])).to eq nil
    end
  end

  describe "#skip_event" do
    context 'AND expression' do
      let(:expression) { {
        :and=>
          {:"record.user_ip"=>"::1", :"record.user.role"=>"member"}
        }
      }

      it 'should skip event' do
        expect(event_mailer.send(:skip_event, event, expression)).to eq true
      end

      it 'shouldnt skip event' do
        expression[:and][:"record.user.role"] = 'admin'
        expect(event_mailer.send(:skip_event, event, expression)).to eq false
      end
    end

    context 'OR expression' do
      let(:expression) { {
        :or=>
          {:"record.user_ip"=>"::1", :"record.user.role"=>"member"}
        }
      }

      it 'shouldnt skip event' do
        expect(event_mailer.send(:skip_event, event, expression)).to eq false
      end

      it 'should skip event' do
        expression[:or][:"record.user_ip"] = 'test'
        expect(event_mailer.send(:skip_event, event, expression)).to eq true
      end
    end

    context 'NOT expression' do
      let(:expression) { {
        :not=>
          {:"record.user_ip"=>"::1"}
        }
      }

      it 'shoul skip event' do
        expect(event_mailer.send(:skip_event, event, expression)).to eq true
      end

      it 'shouldnt skip event' do
        expression[:not][:"record.user_ip"] = 'test'
        expect(event_mailer.send(:skip_event, event, expression)).to eq false
      end

      it 'should skip event' do
        expression[:not][:'record.user.email'] = 'admin@barong.io'
        expect(event_mailer.send(:skip_event, event, expression)).to eq true
      end

      it 'shouldnt skip event' do
        expression[:not][:'record.user.email'] = 'admin1@barong.io'
        expect(event_mailer.send(:skip_event, event, expression)).to eq false
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Admin::Activities do
  include_context 'bearer authentication'
  include_context 'geoip mock'

  describe 'GET /api/v2/admin/activities' do
    let!(:create_admin_permission) do
      create :permission,
             role: 'admin'
    end
    let!(:create_member_permission) do
      create :permission,
             role: 'member'
    end
    let(:do_request) { get '/api/v2/admin/activities', headers: auth_header }

    context 'admin user' do
      let!(:test_user) { create(:user, email: 'testa@gmail.com', role: 'admin') }
      let!(:first_user) { create(:user, email: 'test1@gmail.com') }
      let!(:second_user) { create(:user, email: 'test2@gmail.com') }

      context 'user activities' do
        let!(:create_actitivites) do
          create(:activity, category: 'user', topic: 'session', action: 'login', user: first_user)
          create(:activity, category: 'user', topic: 'session', action: 'login', user: second_user)
          create(:activity, category: 'user', topic: 'otp', action: 'otp::enable', user: second_user)
          create(:activity, category: 'admin', topic: 'otp', action: 'otp::enable', user: second_user)
        end

        it 'doesnt return admin activities' do
          get '/api/v2/admin/activities', headers: auth_header
          activities = JSON.parse(response.body)
          expect(Activity.where(category: 'user').count).to eq activities.count
          expect(Activity.all.count).not_to eq activities.count
        end

        it 'returns list of activities' do
          get '/api/v2/admin/activities', headers: auth_header
          activities = JSON.parse(response.body)
          user_activites = Activity.where(category: 'user')
          expect(user_activites.count).to eq activities.count
          expect(user_activites.last.user_ip).to eq activities[0]['user_ip']
          expect(user_activites.last.user_agent).to eq activities[0]['user_agent']
          expect(Barong::GeoIP.info(ip: user_activites.last.user_ip, key: :country)).to eq activities[0]['user_ip_country']
          expect(user_activites.last.topic).to eq activities[0]['topic']
          expect(user_activites.last.action).to eq activities[0]['action']
          expect(user_activites.last.result).to eq activities[0]['result']
          expect(user_activites.last.user.email).to eq activities[0]['user']['email']
          expect(first_user.email).to eq activities[2]['user']['email']
        end

        it 'returns list of activities filtered by action' do
          get '/api/v2/admin/activities', headers: auth_header, params: {action: 'login'}
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 2
        end

        it 'returns list of activities filtered by uid' do
          get '/api/v2/admin/activities', headers: auth_header, params: {uid: first_user.uid}
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by email' do
          get '/api/v2/admin/activities', headers: auth_header, params: {email: first_user.email}
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by topic' do
          get '/api/v2/admin/activities', headers: auth_header, params: {topic: 'otp'}
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by action and  uid' do
          get '/api/v2/admin/activities', headers: auth_header, params: {topic: 'session', action: 'login', uid: second_user.uid}
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end
      end

      context 'admin activities' do
        let!(:create_actitivites) do
          create(:activity, topic: 'session', action: 'login', user: first_user, category: 'admin', target_uid: second_user.uid)
          create(:activity, topic: 'session', action: 'login', user: second_user, category: 'admin')
          create(:activity, topic: 'otp', action: 'otp::enable', user: second_user, category: 'admin', target_uid: second_user.uid)
        end

        it 'returns list of activities' do
          get '/api/v2/admin/activities/admin', headers: auth_header
          activities = JSON.parse(response.body)

          expect(Activity.count).to eq activities.count
          expect(Activity.third.user_ip).to eq activities[0]['user_ip']
          expect(Barong::GeoIP.info(ip: Activity.third.user_ip, key: :country)).to eq activities[0]['user_ip_country']
          expect(Activity.third.user_agent).to eq activities[0]['user_agent']
          expect(Activity.third.topic).to eq activities[0]['topic']
          expect(Activity.third.action).to eq activities[0]['action']
          expect(Activity.third.result).to eq activities[0]['result']
          expect(Activity.third.user.email).to eq activities[0]['admin']['email']
          expect(Activity.third.target.email).to eq activities[0]['target']['email']
          expect(Activity.first.user.email).to eq activities[2]['admin']['email']
          expect(Activity.first.target.email).to eq activities[2]['target']['email']
        end

        it 'returns list of activities filtered by action' do
          get '/api/v2/admin/activities/admin', headers: auth_header, params: { action: 'login' }
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 2
        end

        it 'returns list of activities filtered by uid' do
          get '/api/v2/admin/activities/admin', headers: auth_header, params: { uid: first_user.uid }
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by email' do
          get '/api/v2/admin/activities/admin', headers: auth_header, params: { email: first_user.email }
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by topic' do
          get '/api/v2/admin/activities/admin', headers: auth_header, params: { topic: 'otp' }
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by action and  uid' do
          get '/api/v2/admin/activities/admin', headers: auth_header, params: { topic: 'session', action: 'login', uid: second_user.uid }
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 1
        end

        it 'returns list of activities filtered by affected user' do
          get '/api/v2/admin/activities/admin', headers: auth_header, params: { target_uid: second_user.uid }
          activities = JSON.parse(response.body)
          expect(activities.count).to eq 2
        end
      end
    end
  end
end

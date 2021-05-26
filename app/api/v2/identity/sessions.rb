# frozen_string_literal: true

require_dependency 'barong/jwt'

module API::V2
  module Identity
    class Sessions < Grape::API
      helpers do
        def get_user(email)
          user = User.find_by(email: email)
          error!({ errors: ['identity.session.invalid_params'] }, 401) unless user

          if user.state == 'banned'
            login_error!(reason: 'Your account is banned', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'banned')
          end

          if user.state == 'deleted'
            login_error!(reason: 'Your account is deleted', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'deleted')
          end

          # if user is not active or pending, then return 401
          unless user.state.in?(%w[active pending])
            login_error!(reason: 'Your account is not active', error_code: 401,
                         user: user.id, action: 'login', result: 'failed', error_text: 'not_active')
          end
          user
        end
      end

      desc 'Session related routes'
      resource :sessions do
        desc 'Start a new session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :email
          requires :password
          optional :captcha_response,
                   types: { value: [String, Hash], message: 'identity.session.invalid_captcha_format' },
                   desc: 'Response from captcha widget'
          optional :otp_code,
                   type: String,
                   desc: 'Code from Google Authenticator'
        end
        post do
          verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')

          declared_params = declared(params, include_missing: false)
          user = get_user(declared_params[:email])

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          unless user.otp
            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            csrf_token = open_session(user)
            publish_session_create(user)

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
            return status 200
          end

          error!({ errors: ['identity.session.missing_otp'] }, 401) if declared_params[:otp_code].blank?
          unless TOTPService.validate?(user.uid, declared_params[:otp_code])
            login_error!(reason: 'OTP code is invalid', error_code: 403,
                         user: user.id, action: 'login::2fa', result: 'failed', error_text: 'invalid_otp')
          end

          activity_record(user: user.id, action: 'login::2fa', result: 'succeed', topic: 'session')
          csrf_token = open_session(user)
          publish_session_create(user)

          present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          status(200)
        end

        desc 'Destroy current session',
          failure: [
            { code: 400, message: 'Required params are empty' },
            { code: 404, message: 'Record is not found' }
          ],
          success: { code: 200, message: 'Session was destroyed' }
        delete do
          user = User.find_by(uid: session[:uid])
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          activity_record(user: user.id, action: 'logout', result: 'succeed', topic: 'session')

          Barong::RedisSession.delete(user.uid, session.id)
          session.destroy

          status(200)
        end

        desc 'Auth0 authentication by id_token',
             success: { code: 200, message: 'User authenticated' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ]
        params do
          requires :id_token,
                   type: String,
                   allow_blank: false,
                   desc: 'ID Token'
        end
        post '/auth0' do
          begin
            # Decode ID token to get user info
            claims = Barong::Auth0::JWT.verify(params[:id_token]).first
            error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless claims.key?('email')
            user = User.find_by(email: claims['email'])

            # If there is no user in platform and user email verified from id_token
            # system will create user
            if user.blank? && claims['email_verified']
              user = User.create!(email: claims['email'], state: 'active')
              user.labels.create!(scope: 'private', key: 'email', value: 'verified')
            elsif claims['email_verified'] == false
              error!({ errors: ['identity.session.auth0.invalid_params'] }, 401) unless user
            end

            activity_record(user: user.id, action: 'login', result: 'succeed', topic: 'session')
            csrf_token = open_session(user)
            publish_session_create(user)

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
          rescue StandardError => e
            report_exception(e)
            error!({ errors: ['identity.session.auth0.invalid_params'] }, 422)
          end
        end

        namespace :switch do
          desc 'Switch user session',
               success: { code: 200, message: 'Session was switched' },
               failure: [
                 { code: 404, message: 'Record is not found' }
               ]
          params do
            optional :oid,
                     type: String,
                     desc: 'Organization OID'
          end
          post do
            user = User.find_by(uid: session[:uid])
            error!({ errors: ['identity.session.not_found'] }, 404) unless user

            aid = params[:oid]
            unless aid.nil?
              # Check account in the organization that user belong to
              members = Membership.joins('LEFT JOIN organizations ON organizations.id = memberships.parent_id')
                                  .where(user_id: user.id)
                                  .select('memberships.*,organizations.name, organizations.parent_id')
                                  .pluck(:organization_id, :'organizations.name', :'organizations.parent_id')
                                  .map { |id, name, pid| { id: id, name: name, pid: pid } }
              error!({ errors: ['identity.member.not_found'] }, 404) if members.nil? || members.length.zero?

              # Check user is barong organization admin or not
              if members.first[:id].zero?
                # User is barong organization admin
                oids = Organization.all.pluck(:id)
              else
                # User is organizationn admin/account
                oids = Organization.where(id: members.pluck(:id)).pluck(:id)
                members.select { |m| m[:pid].nil? }.each do |m|
                  oids.concat(Organization.where(parent_id: m[:id]).pluck(:id))
                end
              end

              org = Organization.find_by_oid(aid)
              error!({ errors: ['identity.member.not_found'] }, 404) if org.nil?
              error!({ errors: ['identity.member.not_found'] }, 404) unless oids.include? org.id

              # Set oid as aid for default case of switched as organization admin
              oid = aid

              unless org.parent_id.nil?
                organization = Organization.find(org.parent_id)
                error!({ errors: ['identity.organization.not_found'] }, 404) unless organization

                # Set oid to be root organization in case of switched as organization account
                oid = organization.oid
              end

              account = Membership.where(user_id: user.id, parent_id: org.id)
              account = Membership.where(user_id: user.id) if account.length.zero?
              account = account.first

              switch = {
                oid: oid,
                aid: aid,
                account_role: account.role
              }
            end

            activity_record(user: user.id, action: (aid.nil? ? 'switch::user' : 'switch::orgnization'),
                            result: 'succeed', topic: 'session')
            Barong::RedisSession.delete(user.uid, session.id)
            session.destroy

            if switch.nil?
              csrf_token = open_session(user)
              publish_session_create(user)
            else
              csrf_token = open_session_switch(user, switch)
              publish_session_switch(user, switch)
            end

            present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
            status(200)
          end
        end
      end
    end
  end
end

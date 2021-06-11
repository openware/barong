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

        def user_uid
          # To identiy origin user by session[:rid]
          # if exist, user comes from switched mode use [:rid]; else use [:uid]
          session[:rid].present? ? session[:rid] : session[:uid]
        end

        def switch_session(user, switch, switch_oid, role, csrf_token)
          open_session_switch(user, switch, csrf_token)
          publish_session_switch(user, switch)
          uid = if switch[:oid].nil?
                  # switch as user
                  switch[:uid]
                else
                  # switch as organization
                  switch[:rid]
                end
          current_user = ::User.find_by_uid(uid)
          current_user.current_oid = switch_oid
          current_user.current_organization = ::Organization.find_by_oid(switch_oid)
          current_user.role = role
          current_user.current_user_role = user.role

          {
            token: csrf_token,
            user: current_user
          }
        end

        def get_switch_session(user, switch_oid, is_switch_session)
          org = ::Organization.find_by_oid(switch_oid)
          error!({ errors: ['identity.member.not_found'] }, 404) if org.nil?

          role = org.parent_organization.nil? ? 'org-admin' : 'org-member'
          if is_switch_session
            # User is organization admin/account
            # Check account in the organization that user belong to
            members = ::Membership.with_all_organizations
                                  .with_users(user.id)
                                  .select('memberships.*,organizations.name, organizations.parent_organization')
                                  .pluck(:organization_id, :'organizations.name', :'organizations.parent_organization')
                                  .map { |id, name, pid| { id: id, name: name, pid: pid } }
            error!({ errors: ['identity.member.not_found'] }, 404) if members.nil? || members.length.zero?

            oids = ::Organization.where(id: members.pluck(:id)).pluck(:id)
            members.select { |m| m[:pid].nil? }.each do |m|
              oids.concat(::Organization.with_parents(m[:id]).pluck(:id))
            end

            member = ::Membership.with_users(user.id)
                                 .joins(:organization)
                                 .where(organizations: { oid: switch_oid })
            # Set role as organization role
            role = member.first.role if member.length.positive?

            error!({ errors: ['identity.member.not_found'] }, 404) if oids.length.zero?
            error!({ errors: ['identity.member.not_found'] }, 404) unless oids.include? org.id
          end

          if org.parent_organization.nil?
            # User switch as organization admin
            organization_oid = switch_oid
          else
            # User switch as organization subunit
            organization = ::Organization.find(org.parent_organization)
            error!({ errors: ['identity.organization.not_found'] }, 404) unless organization

            organization_oid = organization.oid
          end

          {
            uid: switch_oid,
            oid: organization_oid,
            rid: user.uid,
            role: role,
            username: user.username,
            email: user.email,
            level: user.level,
            otp: user.otp,
            state: user.state,
            referral_uid: user.referral_uid,
            user_role: user.role
          }
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
          # Verify captcha only when otp_code is not provided
          verify_captcha!(response: params['captcha_response'], endpoint: 'session_create') if params[:otp_code].nil?

          declared_params = declared(params, include_missing: false)
          user = get_user(declared_params[:email])

          # Verify captcha if user has disabled otp, but otp_code is provided
          if user.otp == false && declared_params[:otp_code].present?
            verify_captcha!(response: params['captcha_response'], endpoint: 'session_create')
          end

          unless user.authenticate(declared_params[:password])
            login_error!(reason: 'Invalid Email or Password', error_code: 401, user: user.id,
                         action: 'login', result: 'failed', error_text: 'invalid_params')
          end

          action = user.otp ? 'login::2fa' : 'login'
          if user.otp
            error!({ errors: ['identity.session.missing_otp'] }, 401) if declared_params[:otp_code].blank?
            unless TOTPService.validate?(user.uid, declared_params[:otp_code])
              login_error!(reason: 'OTP code is invalid', error_code: 403,
                           user: user.id, action: action, result: 'failed', error_text: 'invalid_otp')
            end
          end

          # Destroy switch session first
          if session.present?
            Barong::RedisSession.delete(user_uid, session.id)
            session.destroy
          end

          members = ::Membership.where(user_id: user.id)
          csrf_token = SecureRandom.hex(10)
          if members.length.zero?
            # Normal session mode proceed
            activity_record(user: user.id, action: action, result: 'succeed', topic: 'session')
            open_session(user, csrf_token)
            publish_session_create(user)
            current_user = user
          else
            switch_oid = members.first.organization.oid
            switch = get_switch_session(user, switch_oid, true)
            role = switch[:role]

            # Switch session mode proceed
            org_session = switch_session(user, switch, switch_oid, role, csrf_token)
            csrf_token = org_session[:token]
            current_user = org_session[:user]
          end

          present current_user, with: API::V2::Entities::UserWithOrganization, csrf_token: csrf_token
          status(200)
        end

        desc 'Destroy current session',
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 404, message: 'Record is not found' }
             ],
             success: { code: 200, message: 'Session was destroyed' }
        delete do
          user = User.find_by(uid: user_uid)
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
          csrf_token = SecureRandom.hex(10)
          open_session(user, csrf_token)
          publish_session_create(user)

          present user, with: API::V2::Entities::UserWithFullInfo, csrf_token: csrf_token
        rescue StandardError => e
          report_exception(e)
          error!({ errors: ['identity.session.auth0.invalid_params'] }, 422)
        end

        namespace :switch do
          desc 'Switch user session as organization user',
               success: { code: 200, message: 'Session was switched' },
               failure: [
                 { code: 404, message: 'Record is not found' }
               ]
          params do
            optional :oid,
                     type: String,
                     desc: 'Organization OID'
            optional :uid,
                     type: String,
                     desc: 'User UID'
          end
          post do
            user = User.find_by_uid(user_uid)
            error!({ errors: ['identity.session.not_found'] }, 404) unless user

            switch_oid = params[:oid]
            switch_uid = params[:uid]
            if !switch_oid.nil? || !switch_uid.nil?
              # Check user has AdminSwitchSession/SwitchSession ability
              is_admin_switch_session = organization_ability? :read, ::AdminSwitchSession
              is_switch_session = organization_ability? :read, ::SwitchSession

              if !is_admin_switch_session && !is_switch_session
                error!({ errors: ['organization.ability.not_permitted'] },
                       401)
              end

              if switch_oid.nil?
                # Switch to individual user
                error!({ errors: ['required.params.missing'] }, 400) if switch_uid.nil?
                error!({ errors: ['organization.ability.not_permitted'] }, 401) unless is_admin_switch_session

                switch_user = User.find_by_uid(switch_uid)
                error!({ errors: ['identity.member.not_found'] }, 404) if switch_user.nil?

                # User cannot belong to any organization
                members = Membership.where(user_id: switch_user.id)
                error!({ errors: ['organization.ability.not_permitted'] }, 401) if members.length.positive?

                # Admin with ability AdminSwitchSession switch to user; set role, email with his role
                switch = {
                  uid: switch_user.uid,
                  username: switch_user.username,
                  email: switch_user.email,
                  role: switch_user.role,
                  level: switch_user.level,
                  otp: switch_user.otp,
                  state: switch_user.state,
                  referral_uid: switch_user.referral_uid,
                  created_at: switch_user.created_at,
                  updated_at: switch_user.updated_at,
                  oid: nil,
                  rid: user.uid,
                  user_role: user.role
                }
                role = switch_user.role
              else
                # Switch to organization/subunit
                error!({ errors: ['organization.ability.not_permitted'] }, 401) unless switch_uid.nil?

                switch = get_switch_session(user, switch_oid, is_switch_session)
                role = switch[:role]
              end
            end

            csrf_token = if session.present? && session[:csrf_token].present?
                           session[:csrf_token]
                         else
                           SecureRandom.hex(10)
                         end
            activity_record(user: user.id, action: (switch_oid.nil? ? 'switch::user' : 'switch::orgnization'),
                            result: 'succeed', topic: 'session')
            Barong::RedisSession.delete(user.uid, session.id)
            session.destroy

            if switch.nil?
              # Destroy switch session mode and take user back to individual session mode
              open_session(user, csrf_token)
              publish_session_create(user)
              current_user = user
            else
              # Switch session mode proceed
              org_session = switch_session(user, switch, switch_oid, role, csrf_token)
              csrf_token = org_session[:token]
              current_user = org_session[:user]
            end

            present current_user, with: API::V2::Entities::UserWithOrganization, csrf_token: csrf_token
            status(200)
          end
        end
      end
    end
  end
end

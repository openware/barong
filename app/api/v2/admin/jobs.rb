# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over jobs table
      class Jobs < Grape::API
        resource :jobs do
          helpers ::API::V2::NamedParams

          desc 'Create new job',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'Job was created' }
          params do
            requires :description,
                     type: String,
                     allow_blank: false,
                     desc: 'job description'
            requires :job_type,
                     type: String,
                     values: { value: -> { ['maintenance'] }, message: 'admin.job.invalid_job_type'},
                     desc: 'job type'
            requires :start_at,
                     type: DateTime,
                     desc: 'time to run start job'
            optional :finish_at,
                     type: DateTime,
                     desc: 'time to run finish job'
            optional :whitelist_ip,
                     type: String,
                     desc: 'whitelist IP address'
          end
          post do
            admin_authorize! :create, Job
            admin_authorize! :create, Restriction
            
            # Create or find maintenace restriction
            restriction = Restriction.find_or_create_by(category: params[:job_type], scope: 'all', value: 'all', state: 'disabled')

            # Set parameters
            declared_params = declared(params, include_missing: false)
            job_params = declared_params.merge(reference: restriction)
                                        .except(:whitelist_ip)

            # Create new job
            job = Job.new(job_params)
            code_error!(job.errors.details, 422) unless job.save

            # Create new whitelist restriction for specific IP address if present
            if params[:whitelist_ip].present?
              Restriction.create!(scope: 'ip', category: 'whitelist', value: params[:whitelist_ip])
              
              # clear cached restrictions, so they will be freshly refetched on the next call to /auth
              Rails.cache.delete('restrictions')
            end

            status 200
          end

          # GET request
          # List for existing Jobs with pagination

          # PUT request
          # Update of existing Job mainly it will be used to disable Job and disable reference
          # Also, we can add here the ability to change starts_at and finish_at (Bonus Task)
        end
      end
    end
  end
end

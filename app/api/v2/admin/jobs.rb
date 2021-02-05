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
            requires :type,
                     type: String,
                     values: { value: -> { Job::TYPES }, message: 'admin.job.invalid_type'},
                     desc: 'job type'
            requires :start_at,
                     type: DateTime,
                     desc: 'date and time to run start job'
            optional :finish_at,
                     type: DateTime,
                     desc: 'date and time to run finish job'
            optional :whitelist_ip,
                     type: Array[String],
                     allow_blank: true,
                     desc: 'whitelist IP addresses'
          end
          post do
            admin_authorize! :create, Restriction
            admin_authorize! :create, Job
            admin_authorize! :create, Jobbing
            
            # Find or create maintenance restriction
            maintenance = Restriction.find_or_create_by(category: params[:type], scope: 'all', value: 'all', state: 'disabled')
            error!({ errors: ['admin.job.cant_find_or_create_maintenance_restriction'] }, 422) unless maintenance.id.present?
            
            # check existing pending and active jobs
            existing_jobs = maintenance.jobs.pending + maintenance.jobs.active
            error!({ errors: ['admin.job.cant_create_new_job_for_existing_maintenance'] }, 422) unless existing_jobs.empty?

            # Set parameters
            declared_params = declared(params, include_missing: false)
            job_params = declared_params.merge(state: "pending").except(:whitelist_ip)

            # Create restrictions list
            restrictions = [maintenance]

            # Map whitelist restrictions to job
            if params[:whitelist_ip].present? && params[:whitelist_ip].any?
              params[:whitelist_ip].each do |ip|
                whitelist = Restriction.find_or_create_by(category: 'whitelist', scope: 'ip', value: ip, state: :disabled)
                code_error!(whitelist.errors.details, 422) unless whitelist.save

                restrictions << whitelist
              end
            end

            # Create new job
            job = Job.new(job_params)
            code_error!(job.errors.details, 422) unless job.save

            # Map restrictions to job
            restrictions.each do |restriction|
              restriction_job = Jobbing.new(job: job, reference: restriction)
              code_error!(restriction_job.errors.details, 422) unless restriction_job.save
            end

            # clear cached restrictions, so they will be freshly refetched on the next call to /auth
            Rails.cache.delete('restrictions')

            status 200
          end

          desc 'Returns list of jobs as a paginated collection',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: API::V2::Entities::Restriction
          params do
            optional :type,
                     allow_blank: false,
                     values: { value: -> { Job::TYPES }, message: 'admin.job.invalid_type'}
            optional :state,
                     allow_blank: false,
                     values: { value: -> { Job::STATES }, message: 'admin.job.invalid_state'}
            use :pagination_filters
          end
          get do
            admin_authorize! :read, Job

            Job.all.order(id: :desc)
              .tap { |q| q.where!(type: params[:type]) if params[:type].present? }
              .tap { |q| q.where!(state: params[:state]) if params[:state].present? }
              .tap { |q| present paginate(q), with: API::V2::Entities::Job }
          end

          desc 'Update job',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ],
            success: { code: 200, message: 'Job was updated' }
          params do
            requires :id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Job id'
            requires :state,
                     type: String,
                     allow_blank: false,
                     values: { value: -> { Job::STATES }, message: 'admin.job.invalid_state' }
            optional :description,
                     type: String,
                     allow_blank: false,
                     desc: 'job description'
            optional :start_at,
                     type: DateTime,
                     desc: 'date and time to run start job'
            optional :finish_at,
                     type: DateTime,
                     desc: 'date and time to run finish job'
          end
          put '/:id' do
            admin_authorize! :update, Job

            target_job = Job.find_by(id: params[:id])

            error!({ errors: ['admin.job.doesnt_exist'] }, 404) if target_job.nil?

            unless target_job.update(declared(params, include_missing: false))
              code_error!(target_job.errors.details, 422)
            end

            # clear cached restrictions, so they will be freshly refetched on the next call to /auth
            Rails.cache.delete('restrictions')

            status 200
          end
        end
      end
    end
  end
end

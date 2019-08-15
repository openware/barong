# frozen_string_literal: true

module API::V2
  module Management
    # Documents server-to-server API
    class Documents < Grape::API
      desc 'Documents related routes'
      resource :documents do
        helpers do
          def parse_file_data(upload, name, ext)
            decoded_file = Base64.strict_decode64(upload)
            file = Tempfile.new([name, ext])
            file.binmode
            file.write decoded_file

            return file
          end
        end

        desc 'Push documents to barong DB' do
          @settings[:scope] = :write_documents
          success API::V2::Entities::UserWithProfile
        end

        params do
          requires :uid, type: String, allow_blank: false, desc: 'User uid'
          requires :doc_type,
                   type: String,
                   allow_blank: false,
                   desc: 'Document type'
          requires :doc_number,
                   type: String,
                   allow_blank: false,
                   desc: 'Document number'
          requires :filename,
                   type: String,
                   allow_blank: false,
                   desc: 'Document name'
          requires :file_ext,
                   type: String,
                   allow_blank: false,
                   desc: 'Document file extension'
          requires :upload,
                   type: String,
                   desc: 'Base64 encoded document'
          optional :doc_expire,
                   type: { value: Date, message: "management.documents.expire_not_a_date" },
                   allow_blank: false,
                   desc: 'Document expiration date'
          optional :metadata, type: Hash, desc: 'Any key:value pairs'
        end

        post do
          user = User.find_by!(uid: params[:uid])
          error!(errors: ['user doesnt exist']) unless user

          file = parse_file_data(params[:upload], params[:filename], params[:file_ext])

          doc = user.documents.new(declared(params).except(:upload, :uid, :filename, :file_ext).merge(upload: file))
          error!(doc.errors.full_messages.to_sentence, 422) unless doc.save

          status 201
        end
      end
    end
  end
end

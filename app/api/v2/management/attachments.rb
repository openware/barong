# frozen_string_literal: true

module API::V2
  module Management
    class Attachments < Grape::API
      resource :attachments do
        helpers do
          def parse_file_data(upload, name, ext)
            decoded_file = Base64.strict_decode64(upload)
            file = Tempfile.new([name, ext])
            file.binmode
            file.write decoded_file

            file
          end
        end

        desc 'Upload a new attachment for given user' do
          @settings[:scope] = :write_attachments
          success API::V2::Management::Entities::Attachment
        end
        params do
          optional :uid, type: String, desc: 'User uid'
          requires :filename,
                   type: String,
                   allow_blank: false,
                   desc: 'Attachment name'
          requires :file_ext,
                   type: String,
                   allow_blank: false,
                   desc: 'Attachment file extension'
          requires :upload,
                   type: String,
                   desc: 'Base64 encoded attachment'
        end
        post do
          user = User.find_by(uid: params[:uid])

          file = parse_file_data(params[:upload], params[:filename], params[:file_ext])

          attachment = Attachment.new(declared(params).except(:upload, :uid, :filename, :file_ext).merge(user: user, upload: file))
          error!(attachment.errors.full_messages.to_sentence, 422) unless attachment.save

          present attachment, with: API::V2::Management::Entities::Attachment
          status 201
        end
      end
    end
  end
end

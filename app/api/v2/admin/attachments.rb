module API
  module V2
    module Admin
      class Attachments < Grape::API
        resource :attachments do
          desc 'Returns attachment url'
          params do
            requires :id, type: Integer, desc: 'Attachment id'
          end
          get ':id/upload' do
            attachment = Attachment.find(params[:id])

            present(attachment.upload)
            status 200
          end
        end
      end
    end
  end
end

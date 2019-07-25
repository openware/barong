# frozen_string_literal: true

require 'spec_helper'

describe 'Documents API test' do
  include_context 'bearer authentication'
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let!(:image) { fixture_file_upload('/files/documents_test.jpg', 'image/jpg') }

  describe 'POST /api/v2/resource/documents/' do
    let(:params) do
      {
        doc_type: 'Passport',
        doc_expire: '2020-01-22',
        doc_number: 'AA1234BB',
        upload: [
          image
        ]
      }
    end

    let!(:optional_params) do
      {
        metadata: {
          country: Faker::Address.country
        }
      }
    end

    let(:last_document) { Document.last }

    it 'saves 10 documents successfully' do
      10.times do
        post '/api/v2/resource/documents', headers: auth_header,
                                           params: {
                                             doc_type: 'Passport',
                                             doc_expire: '2020-01-22',
                                             doc_number: 'AA1234BB',
                                             upload: [fixture_file_upload('/files/documents_test.jpg', 'image/jpg')]
                                           }
      end

      expect(response.status).to eq(201)
    end

    it 'renders an error when max documents already reached' do
      11.times do
        post '/api/v2/resource/documents', headers: auth_header,
                                           params: {
                                             doc_type: 'Passport',
                                             doc_expire: '2020-01-22',
                                             doc_number: 'AA1234BB',
                                             upload: [fixture_file_upload('/files/documents_test.jpg', 'image/jpg')]
                                           }
      end

      expect(response.status).to eq(400)
      expect_body.to eq(errors: ["resource.documents.limit_will_be_reached"])
    end

    it 'uploads 2 files at once' do
      post '/api/v2/resource/documents', headers: auth_header,
                                         params: {
                                           doc_type: 'Passport',
                                           doc_expire: '2020-01-22',
                                           doc_number: 'AA1234BB',
                                           upload: [
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                           ]
                                         }
      expect(response.status).to eq(201)
      expect(test_user.documents.length).to eq(2)
    end

    it 'uploads 3 files at once' do
      post '/api/v2/resource/documents', headers: auth_header,
                                         params: {
                                           doc_type: 'Passport',
                                           doc_expire: '2020-01-22',
                                           doc_number: 'AA1234BB',
                                           upload: [
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                          ]
                                         }
      expect(response.status).to eq(201)
      expect(test_user.documents.length).to eq(3)
    end

    it 'doesn\'t upload more than 10 files at once' do
      post '/api/v2/resource/documents', headers: auth_header,
                                         params: {
                                           doc_type: 'Passport',
                                           doc_expire: '2020-01-22',
                                           doc_number: 'AA1234BB',
                                           upload: [
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg'),
                                             fixture_file_upload('/files/documents_test.jpg', 'image/jpg')
                                         ]
                                         }
      expect(response.status).to eq(400)
    end

    it 'Checks if params are ok and returns success' do
      post '/api/v2/resource/documents', headers: auth_header, params: params
      expect(response.status).to eq(201)
    end

    it 'Creates document with optional params and returns success' do
      post '/api/v2/resource/documents', headers: auth_header, params: params.merge(optional_params)
      expect(response.status).to eq(201)
      expect(last_document.metadata.symbolize_keys).to eq(optional_params[:metadata])
    end

    it 'Checks provided params and returns error, cause some of them are not valid or absent' do
      post '/api/v2/resource/documents', params: params.except(:doc_type), headers: auth_header
      expect_body.to eq(errors: ['resource.document.missing_doc_type', 'resource.document.empty_doc_type'])
      expect(response.status).to eq(422)

      post '/api/v2/resource/documents', params: params.except(:doc_number), headers: auth_header
      expect_body.to eq(errors: ["resource.document.missing_doc_number", "resource.document.empty_doc_number"])
      expect(response.status).to eq(422)

      post '/api/v2/resource/documents', params: params.except(:upload), headers: auth_header
      expect_body.to eq(errors: ["resource.document.missing_upload"])
      expect(response.status).to eq(422)

      post '/api/v2/resource/documents', params: params.except(:doc_expire).merge(doc_expire: 'blah'), headers: auth_header
      expect_body.to eq(errors: ["resource.documents.expire_not_a_date"])
      expect(response.status).to eq(422)

      params0 = params
      params0[:upload] = [Faker::Avatar.image]
      post '/api/v2/resource/documents', params: params0, headers: auth_header
      expect_body.to eq(errors: ["upload.blank"])
      expect(response.status).to eq(400)
    end

    it 'Does not return error when docs expire is optional' do
      allow(Barong::App.config).to receive(:required_docs_expire).and_return(false)
      post '/api/v2/resource/documents', params: params.except(:doc_expire), headers: auth_header
      expect(response.status).to eq(201)
    end

    it 'Returns error when docs expire is not optional' do
      allow(Barong::App.config).to receive(:required_docs_expire).and_return(true)
      post '/api/v2/resource/documents', params: params.except(:doc_expire), headers: auth_header
      expect(response.status).to eq(422)
      expect_body.to eq({ errors: ["resource.documents.invalid_format"] })
    end

    it 'Returns error when docs expire is not optional and date in past' do
      allow(Barong::App.config).to receive(:required_docs_expire).and_return(true)
      post '/api/v2/resource/documents', params: params.merge({doc_expire: DateTime.now.to_date - 1}), headers: auth_header
      expect(response.status).to eq(422)
      expect_body.to eq({ errors: ["resource.documents.already_expired"] })
    end

    it 'Returns user all his documents' do
      post '/api/v2/resource/documents', params: params, headers: auth_header
      expect(response.status).to eq(201)

      get '/api/v2/resource/documents', headers: auth_header
      response_arr = JSON.parse(response.body)
      expect(response_arr.count).to eq(1)
      expect(response_arr.last['upload']).to_not be_nil
      expect(response_arr.last['doc_type']).to eq('Passport')
      expect(response_arr.last['doc_expire']).to eq('2020-01-22')
      expect(response_arr.last['doc_number']).to eq('AA1234BB')
      expect(response.status).to eq(200)
    end

    it 'Returns error without token' do
      post '/api/v2/resource/documents', params: params
      expect(response.status).to eq(401)

      get '/api/v2/resource/documents', params: params
      expect(response.status).to eq(401)
    end
    after(:all) { User.destroy_all }
  end

  context 'event API behavior' do
    let!(:doc_link) { 'http://storage.googleapis.com/cgcx-barong-docs-bucket/uploads/document/upload/29/Nithf7m-full-screen-hd-wallpaper.jpg?GoogleAccessId=GOOGQBN65D5DW7IOGK727Y5D&Signature=p8IzxyNrkZ%2FVRRwxzG6Cmo%2B49g0%3D&Expires=1563809786' }
    let!(:url) { '/api/v2/resource/documents' }
    let!(:private) {'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBNU5IbFoydXVoeDIwUXZCeUN1TWxDQkl0OWFnYTg5OUZ1VE12TWkxbVFtNTF1S3RYClhnVktlR1h5VytkOVh6eXVoeWdhU1A3VGMxT2NIeFA1dzdqM3NzQXRML2dCWnp5WlUzZ2x4Q01nbFZ4cWEwc3gKZnNhbElhYk9XcTJESnNweU03UFFhNEgxcGFFZnR1TlVxZitXR3FTTTFuemJvREFqblIrOVdVTHNoVXoxN0N6QwppOVhEODAvbkRENUxmWkl1MGdnSTNiVTlLREI3c2Y5YXhLaGF6c0x3WkVxMlNzblRSZkRyY0pIeDQ4QnRIbHB3CkRSTEc2R0kveUVPRmlhUUZPZzFXZk1XMWtlSmp0bW82eFpXWUNORnZHK3FtM2dieGhiM0ZuK3BiOWl3Z202Ym4KUHJqTzJuaDN2QU0vb24vV205T2U2ZmQwTUI4c2RzakdZRUJtalFJREFRQUJBb0lCQUhWRmJjRVhXeGM4amdwUQptT0lqai9NVy9oOE16T04zNXBBSVA0UUQ2SWpiZTlIdFhwVjlPTEdEN2paVDZkbEpqRmtRb0lnUXNlWkZUNXBOCjdvLzAyRjN3U0RoeGJxYXVWQmFIV1RPd25SNXZnc3NDZXBkeXoyYnp5b2FHcnRUT3BNRUN3eXFXTElONmxIcHoKQUEwd1JJbmJFNk5KMG5YQ3RqM3M2bW80OW1kS0ZicHVJWUNMYlN4Z3JXc3M0YzF0KzBLTUJpUkVadTJPWEJUUgpxYWVOOTZpcEdMUXhuL1BKZWtDYWdLdkxWcm9GanpFN0pleWVwbG5NTmJ0d1hlMzlDQ2pXZGdCbkR3bDV1bjJPCkRzMXQvQUdDNzVqS3ZhOGlaZHkrZmtXWTMyOWdyY3NrenlvakI1cSt3MXRiaFRYcTQ3cEtzeWJPZVlXbWtLaWcKcVpERWM0RUNnWUVBLzZxa0Z4NHd1UmNiKzlmZFhoNDl3U29JUVJNZ0RJcXFnQnEzNXpNcW9FMEV0bnRwc1dTWAoxL1VqMU5ZWWViTzFpcFVTUWNIRjFyZGVuZThPeUN1MkwwTlZJbkUwMFlkZ0RSY2VKVEhETitvOXFKZFI1YlltCnI3WGpqUmhKYmR4eVBUQmI4NnhMYlEyRGMrRlR5UkpHc1hZb3RKMitZTUxTRXM4dXJ3Qmw3clVDZ1lFQTVSNUsKdUcwSEl3SG10amdjYWxKQW94REo1NDZBKzZ6QjBRRzZDSlJ6aFhoQmZrQjdLU000TDM1Zm9VV0prL04yWjFFVAprUXNtdnV2Q0xoZDVvVTBFUWdhMGpiOHdFVzZuUWl1L096UFAzVlZ1ZXplSnZHcDlXWElwdFVoQXBONWQ3aTZ4Cjh4OXB6VUVJcWNkOHNxUjNRK1pNQjBlTHlPcGpsUUwyTFJJQkoza0NnWUFtRWlQektWUzZDeDNvcDZGWUpZcXUKbS9LMHRnTmN1cjFlN0J1Y2V2c0srYzBNMjEzR3c2TDB6cFV5V1ZzMXJEUUpXZDlwR1ZDN2czeThhZCs2b1ArMQpGQUsyYVVNalBGUnFQcG9Ia2R4dkZCdHdZbkFZazhJNUFnM0xjZVZsVGFGWlNUMDRFTnorZFRldzVzblNORDJBCnFZYXdOcGtsMFh6MHZoTkdqZm1melFLQmdEV0VXZGV5UDlTQmdTNVc5T3d3d2tCVWo1U3l5SllBeUZUVm5tcWEKb2xFdXdiMkh1anpscVI0TzJxK0UycG5nYUd2Qm1GeHN5bVFXRllsR21uWiswdHZKVFNzKzJTOTVOVUJUajV0NApncmtrVjJZWWx1ZVh5Q2U0YnQyVlB1UkR2SlVCK3piYXc0L1ovUGdMVEtrOW1VNFc0UE5pVnRoYlIxOXJEYTJCCll4dWhBb0dCQUpqb2RMSHltOTRZcWs0TDRJLzJ2OUZjK055VXk1MUNoSnZoUzZLUTFRdHY4ZVN5dG1ndUpLUjgKZ3g3eSt2VlVqNFJ1TjFxU3JCNFI2VFhkbGlsNmNIUXI2YW1GM2NhQ1l1allUUVJRcEhyQXVWT3ZOT3RPaTlqcgpodmQ5Tkl1N0U4NHhRbDd0K2J4eFhsbG9XZmErSllyK1JzUzJjL082UStYb2hYcmZWRUZOCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg=='}
    let!(:public) {'LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE1TkhsWjJ1dWh4MjBRdkJ5Q3VNbApDQkl0OWFnYTg5OUZ1VE12TWkxbVFtNTF1S3RYWGdWS2VHWHlXK2Q5WHp5dWh5Z2FTUDdUYzFPY0h4UDV3N2ozCnNzQXRML2dCWnp5WlUzZ2x4Q01nbFZ4cWEwc3hmc2FsSWFiT1dxMkRKc3B5TTdQUWE0SDFwYUVmdHVOVXFmK1cKR3FTTTFuemJvREFqblIrOVdVTHNoVXoxN0N6Q2k5WEQ4MC9uREQ1TGZaSXUwZ2dJM2JVOUtEQjdzZjlheEtoYQp6c0x3WkVxMlNzblRSZkRyY0pIeDQ4QnRIbHB3RFJMRzZHSS95RU9GaWFRRk9nMVdmTVcxa2VKanRtbzZ4WldZCkNORnZHK3FtM2dieGhiM0ZuK3BiOWl3Z202Ym5QcmpPMm5oM3ZBTS9vbi9XbTlPZTZmZDBNQjhzZHNqR1lFQm0KalFJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=='}
    let!(:algorithm) {'RS256'}
    let!(:private_key) { OpenSSL::PKey.read(Base64.urlsafe_decode64(private)) }
    let!(:public_key) { OpenSSL::PKey.read(Base64.urlsafe_decode64(public)) }
    let!(:event) do 
      {
        name: 'model.document.created',
        record: {
          doc_type: 'Passport',
          doc_expire: '2020-01-22',
          doc_number: 'AA1234BB',
          upload: doc_link,
          updated_at:"2019-01-28T08:35:29Z",
          created_at:"2019-01-28T08:35:29ZZ",
          user: {
            uid: 'UID12345',
            email: "example@barong.io",
            role: "member",
            level: 2,
            otp: false,
            state: "active",
            created_at: "2019-01-28T08:35:29Z",
            updated_at: "2019-01-28T08:35:29Z"
          }
        }
      }
    end
    let!(:jwt_payload) do 
      {
        iss:   'barong',
        jti:   SecureRandom.uuid,
        iat:   Time.now.to_i,
        exp:   Time.now.to_i + 60,
        event: event
      }
    end
    let(:request_params) do
      {
        doc_type: 'Passport',
        doc_expire: '2020-01-22',
        doc_number: 'AA1234BB',
        upload: [
          image
        ]
      }
    end

    before do
      allow(EventAPI).to receive(:notify)
    end

    it 'receive model.document.created notify' do
      expect(EventAPI).to receive(:notify).ordered.with('model.user.created', hash_including(:record))
      expect(EventAPI).to receive(:notify).ordered.with('model.document.created', hash_including(:record))

      post url, headers: auth_header, params: request_params
    end

    it 'Fails without encoded url' do
      jwt = JWT::Multisig.generate_jwt jwt_payload, \
        { barong: private_key },
        { barong: algorithm }

      expect (JWT::Multisig.verify_jwt jwt.deep_stringify_keys, \
        { barong: public_key }, { verify_iss: true, iss: "barong", verify_jti: true })
        .to raise_exception

     
    end

    it 'Works with encoded url' do
      event['record']['upload'] = CGI::escape(doc_link)
      jwt_payload = jwt_payload['event'] = event

      jwt = JWT::Multisig.generate_jwt jwt_payload, \
        { barong: private_key },
        { barong: algorithm }

      verification_result = JWT::Multisig.verify_jwt jwt.deep_stringify_keys, \
        { barong: public_key }, { verify_iss: true, iss: "barong", verify_jti: true }

      expect(verification_result).to eq('')
    end
  end
end

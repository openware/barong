# frozen_string_literal: true

describe API::V2::Entities::Activity do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:record) { create(:activity, topic: 'otp', result: 'succeed', action: 'login') }

  subject { OpenStruct.new API::V2::Entities::Activity.represent(record).serializable_hash }

  it { expect(subject.topic).to eq record.topic }
  it { expect(subject.result).to eq record.result }
  it { expect(subject.user_ip).to eq record.user_ip }
  it { expect(subject.action).to eq record.action }
  it { expect(subject.data).to eq record.data }
  it { expect(subject.user_agent).to eq record.user_agent }

  it { expect(subject.created_at).to eq record.created_at.iso8601 }
end

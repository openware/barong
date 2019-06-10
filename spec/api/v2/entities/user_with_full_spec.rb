# frozen_string_literal: true

describe API::V2::Entities::UserWithFullInfo do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:record) { create(:user) }

  subject { OpenStruct.new API::V2::Entities::UserWithFullInfo.represent(record).serializable_hash }

  it { expect(subject.email).to eq record.email }
  it { expect(subject.uid).to eq record.uid }
  it { expect(subject.role).to eq record.role }
  it { expect(subject.level).to eq record.level }
  it { expect(subject.otp).to eq record.otp }
  it { expect(subject.state).to eq record.state }
  it { expect(subject.profile).to eq record.profile }
  it { expect(subject.labels).to eq record.labels }
  it { expect(subject.phones).to eq record.phones }
  it { expect(subject.documents).to eq record.documents }
  it { expect(subject.to_h.keys).not_to include(:activities) }

  it { expect(subject.created_at).to eq record.created_at.iso8601 }
  it { expect(subject.updated_at).to eq record.updated_at&.iso8601 }
end


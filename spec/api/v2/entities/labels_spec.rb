# frozen_string_literal: true

describe API::V2::Entities::Label do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end
  let(:record) { create(:label) }

  subject { OpenStruct.new API::V2::Entities::Label.represent(record).serializable_hash }

  it { expect(subject.key).to eq record.key }
  it { expect(subject.value).to eq record.value }
  it { expect(subject.scope).to eq record.scope }
  it { expect(subject.created_at).to eq record.created_at.iso8601 }
  it { expect(subject.updated_at).to eq record.updated_at&.iso8601 }
end

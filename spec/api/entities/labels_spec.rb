# frozen_string_literal: true

describe Entities::Label do
  let(:record) { create(:label) }

  subject { OpenStruct.new Entities::Label.represent(record).serializable_hash }

  it { expect(subject.key).to eq record.key }
  it { expect(subject.value).to eq record.value }
  it { expect(subject.scope).to eq record.scope }
  it { expect(subject.created_at).to eq record.created_at.iso8601 }
  it { expect(subject.updated_at).to eq record.updated_at&.iso8601 }
end

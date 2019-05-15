# frozen_string_literal: true

describe API::V2::Queries::ActivityFilter do
  let(:initial_scope) { Activity.all }
  let(:params) {{topic: 'session', action: 'login', uid: 'UI12345'}}
  subject { described_class.new(initial_scope).call(params) }

  it 'filters by uid and action' do
    expect(subject.to_sql).to include("`topic` = 'session'")
    expect(subject.to_sql).to include("`action` = 'login'")
    expect(subject.to_sql).to include("`uid` = 'UI12345'")
  end
end

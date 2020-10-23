# frozen_string_literal: true

describe API::V2::Queries::ActivityFilter do
  let(:initial_scope) { Activity.all }
  let(:params) {{topic: 'session', action: 'login', uid: 'UI12345'}}
  subject { described_class.new(initial_scope).call(params) }

  it 'filters by uid and action' do
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      expect(subject.to_sql).to include("`topic` = 'session'")
      expect(subject.to_sql).to include("`action` = 'login'")
      expect(subject.to_sql).to include("`uid` = 'UI12345'")
    when 'PostgreSQL'
      expect(subject.to_sql).to include("\"topic\" = 'session'")
      expect(subject.to_sql).to include("\"action\" = 'login'")
      expect(subject.to_sql).to include("\"uid\" = 'UI12345'")
    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end
end

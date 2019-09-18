# frozen_string_literal: true

require 'rails_helper'

describe 'Document Types configuraton class' do
  context 'testing list function' do
    let(:expected_values) { ['Passport', 'Identity card', 'Driver license', 'Utility Bill', 'Residental', 'Institutional'] }

    before do
      @template = { 'document_types' => ['Passport', 'Identity card', 'Driver license', 'Utility Bill', 'Residental', 'Institutional'] }
      allow(YAML).to receive(:load_file).and_return(@template)
    end

    it 'reads configuration from the file' do
      expect(DocumentTypes.list).to eq(expected_values)
    end

    it 'cache preconfig and doesn\'t read from the file on every call' do
      expect(DocumentTypes.list).to eq(expected_values)

      @template = {}

      expect(DocumentTypes.list).to eq(expected_values)
    end
  end
end

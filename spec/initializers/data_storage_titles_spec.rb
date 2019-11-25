# frozen_string_literal: true

require 'rails_helper'

describe 'Data Storage Titles configuraton class' do
  context 'testing list function' do
    let(:expected_values) { ['personal', 'company'] }

    it 'reads configuration from the file' do
      expect(UserStorageTitles.list).to eq(expected_values)
    end

    it 'cache preconfig and doesn\'t read from the file on every call' do
      expect(UserStorageTitles.list).to eq(expected_values)

      @template = {}

      expect(UserStorageTitles.list).to eq(expected_values)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DocumentsController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/documents/new').to route_to('documents#new')
    end

    it 'routes to #create' do
      expect(post: '/documents').to route_to('documents#create')
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProfilesController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/profiles/new').to route_to('profiles#new')
    end

    it 'routes to #create' do
      expect(post: '/profiles').to route_to('profiles#create')
    end
  end
end

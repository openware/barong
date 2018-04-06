# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::WebsitesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/admin/websites').to route_to('admin/websites#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/websites/new').to route_to('admin/websites#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/websites/1').to route_to('admin/websites#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/websites/1/edit').to route_to('admin/websites#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/websites').to route_to('admin/websites#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/websites/1').to route_to('admin/websites#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/websites/1').to route_to('admin/websites#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/websites/1').to route_to('admin/websites#destroy', id: '1')
    end
  end
end

# frozen_string_literal: true

module Admin
  class ModuleController < BaseController
    class << self
      def inherited(klass)
        klass.instance_eval do
          load_and_authorize_resource
        end
      end
    end
  end
end

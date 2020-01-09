# frozen_string_literal: true

# document types definitions
class DocumentTypes
  class << self
    def list
      @list ||= YAML.load_file(Barong::App.config.config)['document_types']
    end
  end
end

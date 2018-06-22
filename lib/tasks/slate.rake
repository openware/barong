# frozen_string_literal: true

namespace :slate do
  desc 'Swagger definitions to Slate compatible markdown'
  task generate: :environment do
    swagger_input_file_or_url =
      if ARGV[1].present?
        ARGV[1]
      else
        protocol = ENV.fetch('URL_SCHEME', 'http')
        host = ENV.fetch('URL_HOST', 'localhost:3000')
        "#{protocol}://#{host}/api/v1/swagger_doc"
      end
    outfile = Rails.root.join('docs', 'api', 'api.md').to_s
    config_file = Rails.root.join('.widdershins.json').to_s
    executable = 'node node_modules/widdershins/widdershins'

    cmd = "#{executable} #{swagger_input_file_or_url} --outfile=#{outfile} --verbose -e #{config_file}"
    puts cmd

    puts(system(cmd) ? "Success. Check #{outfile}" : 'Error')
  end
end

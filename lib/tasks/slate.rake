# frozen_string_literal: true

namespace :slate do
  desc 'Swagger definitions to Slate compatible markdown'
  task generate: :environment do
    swagger_input_file_or_url =
      if ARGV[1].present?
        ARGV[1]
      else
        "#{Barong.config.url.scheme}://#{Barong.config.url.host}/api/swagger_doc"
      end
    outfile = Rails.root.join('docs', 'index.md').to_s
    executable = 'node node_modules/widdershins/widdershins'

    cmd = "#{executable} #{swagger_input_file_or_url} --outfile=#{outfile} --verbose"
    puts cmd

    puts(system(cmd) ? "Success. Check #{outfile}" : 'Error')
  end
end

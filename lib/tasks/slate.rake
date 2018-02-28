# frozen_string_literal: true

namespace :slate do
  desc 'Swagger definitions to Slate compatible markdown'
  task generate: :environment do
    unless system('which widdershins')
      puts('No widdershins binary found. Run `yarn global add widdershins` to install') && return
    end

    executable = `which widdershins`.strip

    swagger_input_file_or_url =
      if ARGV[1].present?
        ARGV[1]
      else
        protocol = ENV.fetch('URL_SCHEME', 'http')
        host = ENV.fetch('URL_HOST', 'localhost:3000')
        "#{protocol}://#{host}/api/swagger_doc"
      end
    outfile = Rails.root.join('docs', 'index.md').to_s

    cmd = "#{executable} #{swagger_input_file_or_url} --outfile=#{outfile} --verbose"
    puts cmd

    puts(system(cmd) ? "Success. Check #{outfile}" : 'Error')
  end
end

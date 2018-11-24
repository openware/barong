require 'bump'

namespace 'release' do

  desc "Bump the version of the application and build image"
  task :patch do
    Bump::Bump.run("patch", commit_message: '[no ci] Bump')
    Rake::Task["docker:build"].invoke
  end
end

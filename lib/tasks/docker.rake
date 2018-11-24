
namespace 'docker' do

  desc "Build Application container"
  task :build do
    VERSION = File.read("VERSION").chomp
    sh "docker build -t quay.io/openware/barong2:v#{VERSION} ."
    sh "docker build -t quay.io/openware/barong2:latest ."
  end
end

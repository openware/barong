
namespace 'docker' do

  desc "Build Application container"
  task :build do
    sh "docker build -t quay.io/openware/barong2:latest ."
  end
end

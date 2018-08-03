source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

gem "google-protobuf", git: "git@github.com:nishio-dens/protobuf.git", branch: "rails-grpc", glob: "ruby/google-protobuf.gemspec"
gem "grpc", git: "git@github.com:nishio-dens/grpc.git", branch: "rails-grpc", submodules: true

group :development, :test do
  gem "pry"
  gem "pry-doc"
end

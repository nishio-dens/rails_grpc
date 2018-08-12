source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

gem "google-protobuf", git: "git@github.com:nishio-dens/protobuf.git", branch: "rails-grpc", glob: "ruby/google-protobuf.gemspec"

group :development, :test do
  gem "pry"
  gem "pry-doc"
end


lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails_grpc/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_grpc"
  spec.version       = RailsGrpc::VERSION
  spec.authors       = ["Shinsuke Nishio"]
  spec.email         = ["nishio@densan-labs.net"]

  spec.summary       = %q{gRPC for Ruby on Rails}
  spec.description   = %q{gRPC for Ruby on Rails}
  spec.homepage      = "https://github.com/nishio-dens/rails_grpc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails"
  spec.add_dependency "grpc"
  spec.add_dependency "protobuf"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

# rails\_grpc: gRPC for Ruby on Rails

gRPC for Ruby on Rails

## Feature

- Add Autoreload protobuf definition feature in development mode
- Grpc Rails Server
- Add some useful grcp function

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_grpc'
gem "google-protobuf", git: "git@github.com:nishio-dens/protobuf.git", branch: "rails-grpc", glob: "ruby/google-protobuf.gemspec"
```

And then execute:

    $ bundle

## Directory Structure

### /proto

You need to put the protobuf definition in Rails.root/proto dir.

```
$ tree proto
proto
├── ec.deep.proto
├── ec.proto
└── other.proto
```

### /grpc

You need to be careful about the location of grpc service, lib, and model files.

```
# current working dir is Rails.root

$ tree grpc

grpc
├── lib
│   ├── ec.deep_pb.rb
│   ├── ec.deep_services_pb.rb
│   ├── ec_pb.rb
│   ├── ec_services_pb.rb
│   └── other_pb.rb
├── models
│   └── ec
│       └── product.rb
└── services
    └── product_service.rb
```

lib files is the protobuf autogenerate files.

models is a models that you want to extend protobuf models.

services is the protobuf service files.


### example models

```
# grpc/models/ec/product.rb

# You can extend Ec::Product models
class Ec::Product
  PORT = "127.0.0.1:8080"

  def self.all
    service = Ec::ProductService::Stub.new(PORT, :this_channel_is_insecure)
    req = Ec::GetProductsRequest.new
    res = service.get_products(req)

    res.products
  end

  def self.find(id)
    service = Ec::ProductService::Stub.new(PORT, :this_channel_is_insecure)
    req = Ec::GetByProductIdRequest.new(product_id: id)
    res = service.get_by_product_id(req)

    res.product
  end
end
```

### example services

```
# grpc/services/product\_service.rb

module Grpc
  class ProductService < Ec::ProductService::Service
    def get_products(req, _call)
      products = Product.all
      Ec::GetProductsResponse.new(products: products.map(&:to_proto))
    end

    def get_by_product_id(req, _call)
      product = Product.find_by(id: req.product_id)
      if product.present?
        Ec::GetByProductIdResponse.new(product: product.to_proto)
      else
        fail GRPC::BadStatus.new_status_exception(
          GRPC::Core::StatusCodes::ABORTED,
          "product #{req.product_id} not found"
        )
      end
    end
  end
end
```


## Compile Protoc

First, you put protobuf definition in /proto dir, and you need to run compile command.

```
bundle exec rake protoc:compile
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nishio-dens/rails_grpc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsGrpc project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nishio-dens/rails_grpc/blob/master/CODE_OF_CONDUCT.md).

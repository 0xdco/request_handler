# RequestHandler

This gem allows easy and dry handling of requests based on the dry-validation gem for validation and
data coersion. It allows to handle headers, filters, include_options, sorting and of course to
validate the body.

## ToDo

- update documentation
- identify missing features compared to []jsonapi](https://jsonapi.org)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_handler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request_handler

## Usage

To set up a handler, you need to extend the `Dry::RequestHandler::Base class`, providing at least the options block and a to_dto method with the parts you want to use.
To use it, create a new instance of the handler passing in the request, after that you can use the handler.dto method to process and access the data.
Here is a short example, check `spec/integration/request_handler_spec.rb` for a detailed one.

Please note that pagination only considers options that are configured on the server (at least an empty configuration block int the page block), other options sent by the client are ignored and will cause a warning.

```ruby
require "dry-validation"
require "request_handler"
class DemoHandler < RequestHandler::Base
  options do
    # pagination settings
    page do
      default_size 10
      max_size 20
      comments do
        default_size 20
        max_size 100
      end
    end
    # access with handler.page_params

    # include options
    include_options do
      allowed Dry::Types["strict.string"].enum("comments", "author")
    end
    # access with handler.include_params

    # sort options
    sort_options do
      allowed Dry::Types["strict.string"].enum("age", "name")
    end
    # access with handler.sort_params

    # filters
    filter do
      schema(
        Dry::Validation.Form do
          configure do
            option :foo
          end
          required(:name).filled(:str?)
        end
      )
      additional_url_filter %i(user_id id)
      options(->(_handler, _request) { { foo: "bar" } })
      # options({foo: "bar"}) # also works for hash options instead of procs
    end
    # access with handler.filter_params

    # body
    body do
      schema(
        Dry::Validation.JSON do
          configure do
            option :foo
          end
          required(:id).filled(:str?)
        end
      )
      options(->(_handler, _request) { { foo: "bar" } })
      # options({foo: "bar"}) # also works for hash options instead of procs
    end
    # access via handler.body_params

    # also available: handler.headers

    def to_dto
      OpenStruct.new(
        body:    body_params,
        page:    page_params,
        include: include_params,
        filter:  filter_params,
        sort:    sort_params,
        headers: headers
      )
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/runtastic/request_handler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

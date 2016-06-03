# RestfulResourceBugsnag

This gem is aimed at apps using [Bugsnag](https://bugsnag.com) via the Bugsnag
gem and [RestfulResource](https://github.com/carwow/restful_resource).

When a HTTP error is raised from within RestfulResource, useful information is
included on the exception instance. This includes the headers and body of the
response which triggered the exception. This information can be useful when
debuging issues involving HTTP requests but unfortunately Bugsnag will not
include this information by default when reporting errors.

This gem adds a Bugsnag middleware which will add a 'Response' tab to any
RestfulResource::HttpClient errors including this information.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'restful_resource_bugsnag'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restful_resource_bugsnag

## Usage

When configuring Bugsnag, add the following line:

```ruby
Bugsnag.configure do |config|
  # ... other config
  config.middleware.use(RestfulResourceBugsnag::Middleware)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/carwow/restful_resource_bugsnag. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).


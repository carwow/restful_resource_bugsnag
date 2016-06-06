$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'restful_resource_bugsnag'
require 'webmock/rspec'
require 'bugsnag'
require 'restful_resource'

RSpec.configure do |config|
  config.order = "random"

  config.before(:each) do
    WebMock.stub_request(:post, "https://notify.bugsnag.com/")

    Bugsnag.instance_variable_set(:@configuration, Bugsnag::Configuration.new)
    Bugsnag.configure do |bugsnag|
      bugsnag.api_key = "c9d60ae4c7e70c4b6c4ebd3e8056d2b8"
      bugsnag.release_stage = "production"
      bugsnag.delivery_method = :synchronous
      # silence logger in tests
      bugsnag.logger = Logger.new(StringIO.new)

      bugsnag.middleware.use(RestfulResourceBugsnag::Middleware)
    end
  end

  config.after(:each) do
    Bugsnag.configuration.clear_request_data
  end
end

RSpec::Matchers.define :be_notification_for do |expected|
  def exception(actual, field)
    actual["exceptions"].first[field]
  end

  match do |actual|
    errorType = exception(actual, "errorClass")
    message = exception(actual, "message")

    errorType == expected.class.to_s && message == expected.message
  end

  failure_message do |actual|
    "expected error '#{exception(actual, "errorClass")} - #{exception(actual, "message")}' to be '#{expected.class.to_s} - #{expected.message}'"
  end
end

def get_event_from_payload(payload)
  expect(payload["events"].size).to eq(1)
  payload["events"].first
end

def get_tab(event, tab)
  event["metaData"][tab]
end

def sent_notification
  event = nil

  expect(Bugsnag).to (have_requested(:post, "https://notify.bugsnag.com/").with do |request|
    payload = JSON.parse(request.body)
    event = get_event_from_payload(payload)
  end)

  event
end

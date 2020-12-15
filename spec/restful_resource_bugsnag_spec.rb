require 'spec_helper'

describe RestfulResourceBugsnag do
  shared_examples_for RestfulResourceBugsnag do
    before do
      Bugsnag.notify(error)
    end

    it 'sends a notification as usual' do
      expect(sent_notification).to be_notification_for(error)
    end

    describe 'response tab' do
      subject(:response_tab) { get_tab(sent_notification, 'restful_resource_response') }

      it { is_expected.to_not be_nil }
      it { is_expected.to include("status" => error.response.status) }
      it { is_expected.to include("headers" => error.response.headers) }
      it { is_expected.to include("body" => JSON.parse(error.response.body)) }
    end

    describe 'request tab' do
      subject(:request_tab) { get_tab(sent_notification, 'restful_resource_request') }

      it { is_expected.to_not be_nil }
      it { is_expected.to include("method" => error.request.method.to_s) }
      it { is_expected.to include("url" => error.request.url) }
      it { is_expected.to include("body" => JSON.parse(error.request.body)) }
    end
  end

  shared_examples 'passes unparsed body to bugsnag' do
    before do
      Bugsnag.notify(error)
    end

    describe 'response tab' do
      subject(:response_tab) { get_tab(sent_notification, 'restful_resource_response') }

      it { is_expected.to include("body" => error.response.body) }
    end

    describe 'request tab' do
      subject(:request_tab) { get_tab(sent_notification, 'restful_resource_request') }

      it { is_expected.to include("body" => error.request.body) }
    end
  end

  it 'has a version number' do
    expect(RestfulResourceBugsnag::VERSION).not_to be nil
  end

  describe 'when a notification is sent for a normal exception' do
    let(:error) { RuntimeError.new("It broke!") }

    before do
      Bugsnag.notify(error)
    end

    it 'sends the notification as usual' do
      expect(sent_notification).to be_notification_for(error)
    end
  end

  describe 'when a notification is sent for an UnprocessableEntity error' do
    let(:request_body) { '{"msg": "The request body"}' }
    let(:response_body) { '{"msg": "a body"}' }
    let(:response) do
      {
        :status => 422,
        :headers => {
          "content-type" => "text/html; charset=utf-8",
          "content-length" => "6"
        },
        :body => response_body
      }
    end
    let(:error) { make_error(RestfulResource::HttpClient::UnprocessableEntity, response, request_body: request_body) }

    it_behaves_like RestfulResourceBugsnag

    context 'message body is not valid JSON' do
      it_behaves_like 'passes unparsed body to bugsnag' do
        let(:response_body) { 'a body' }
        let(:request_body) { 'The request body' }
      end
    end

    context 'message body is nil' do
      it_behaves_like 'passes unparsed body to bugsnag' do
        let(:response_body) { nil }
        let(:request_body) { nil }
      end
    end
  end

  describe 'when a notification is sent for an OtherHttpError error' do
    let(:request_body) { '{"msg": "The request body"}' }
    let(:response_body) { '{"msg": "Server Error"}' }
    let(:response) do
      {
        :status => 500,
        :headers => {
          "content-type" => "text/html; charset=utf-8",
          "content-length" => "19"
        },
        :body => response_body
      }
    end
    let(:error) { make_error(RestfulResource::HttpClient::OtherHttpError, response, request_body: request_body) }

    it_behaves_like RestfulResourceBugsnag

    context 'message body is not valid JSON' do
      it_behaves_like 'passes unparsed body to bugsnag' do
        let(:response_body) { 'Server Error' }
        let(:request_body) { 'The request body' }
      end
    end

    context 'message body is nil' do
      it_behaves_like 'passes unparsed body to bugsnag' do
        let(:response_body) { nil }
        let(:request_body) { nil }
      end
    end
  end

  describe 'when a notification is sent for an ServiceUnavailable error' do
    let(:request_body) { '{"msg": "The request body"}' }
    let(:response_body) { '{"msg": "Service Unavailable"}' }
    let(:response) do
      {
        :status => 503,
        :headers => {
          "content-type" => "text/html; charset=utf-8",
          "content-length" => "19"
        },
        :body => response_body
      }
    end
    let(:error) { make_error(RestfulResource::HttpClient::ServiceUnavailable, response, request_body: request_body) }

    it_behaves_like RestfulResourceBugsnag

    context 'message body is not valid JSON' do
      it_behaves_like 'passes unparsed body to bugsnag' do
        let(:response_body) { 'Service Unavailable' }
        let(:request_body) { 'The request body' }
      end
    end

    context 'message body is nil' do
      it_behaves_like 'passes unparsed body to bugsnag' do
        let(:response_body) { nil }
        let(:request_body) { nil }
      end
    end

    describe 'grouping ServiceUnavailable errors' do
      let(:error) { make_error(RestfulResource::HttpClient::ServiceUnavailable, response, url: 'http://example.com/path.json') }

      subject { sent_notification }

      before do
        Bugsnag.notify(error)
      end

      it { is_expected.to include("context" => 'HTTP 503: Service unavailable example.com') }
      it { is_expected.to include("groupingHash" => 'HTTP 503: Service unavailable example.com') }
    end
  end

  describe 'when a notification is sent for a Faraday::ConnectionFailed error' do
    let(:response) { nil }

    it_behaves_like RestfulResourceBugsnag do
      let(:error) { make_error(RestfulResource::HttpClient::ClientError, response) }
    end

    describe 'grouping ServiceUnavailable errors' do
      let(:error) { make_error(RestfulResource::HttpClient::ClientError, response, url: 'http://example.com/path.json') }

      subject { sent_notification }

      before do
        Bugsnag.notify(error)
      end

      it { is_expected.to include("context" => 'Client error: Service unavailable example.com') }
      it { is_expected.to include("groupingHash" => 'Client error: Service unavailable example.com') }
    end
  end

  describe 'when a notification is sent for a RestfulResource::HttpClient::Timeout error' do
    let(:response) { nil }

    it_behaves_like RestfulResourceBugsnag do
      let(:error) { make_error(RestfulResource::HttpClient::Timeout, response) }
    end

    describe 'grouping ServiceUnavailable errors' do
      let(:error) { make_error(RestfulResource::HttpClient::Timeout, response, url: 'http://example.com/path.json') }

      subject { sent_notification }

      before do
        Bugsnag.notify(error)
      end

      it { is_expected.to include("context" => 'Client error: Timeout example.com') }
      it { is_expected.to include("groupingHash" => 'Client error: Timeout example.com') }
    end
  end

  # this is some what convoluted in order to recreate how
  # errors are sent in a real app using RestfulResource
  def make_error(type, response, url: 'http://example.com', request_body: '{"msg": "The request body"}')
    error = nil

    begin
      begin
        raise Faraday::ClientError, "The original error"
      rescue Faraday::ClientError => e
        request = RestfulResource::Request.new(:get, url, body: request_body)
        raise type.new(request, response)
      end
    rescue Exception => e
      error = e
    end

    error
  end
end

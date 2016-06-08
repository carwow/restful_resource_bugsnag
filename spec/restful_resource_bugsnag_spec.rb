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
      it { is_expected.to include("body" => error.response.body) }
    end

    describe 'request tab' do
      subject(:request_tab) { get_tab(sent_notification, 'restful_resource_request') }

      it { is_expected.to_not be_nil }
      it { is_expected.to include("method" => error.request.method.to_s) }
      it { is_expected.to include("url" => error.request.url) }
      it { is_expected.to include("accept" => error.request.accept) }
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
    let(:response) do
      {
        :status => 422,
        :headers => {
          "content-type" => "text/html; charset=utf-8",
          "content-length" => "6"
        },
        :body => "a body"
      }
    end

    it_behaves_like RestfulResourceBugsnag do
      let(:error) { make_error(RestfulResource::HttpClient::UnprocessableEntity, response) }
    end
  end

  describe 'when a notification is sent for an OtherHttpError error' do
    let(:response) do
      {
        :status => 503,
        :headers => {
          "content-type" => "text/html; charset=utf-8",
          "content-length" => "19"
        },
        :body => "service unavailable"
      }
    end

    it_behaves_like RestfulResourceBugsnag do
      let(:error) { make_error(RestfulResource::HttpClient::OtherHttpError, response) }
    end
  end

  # this is some what convoluted in order to recreate how
  # errors are sent in a real app using RestfulResource
  def make_error(type, response)
    error = nil

    begin
      begin
        raise Faraday::ClientError, "The original error"
      rescue Faraday::ClientError => e
        request = RestfulResource::Request.new(:get, "http://example.com",
                                          body: "The request body",
                                          accept: "application/vnd.carwow.v2+json")
        raise type.new(request, response)
      end
    rescue Exception => e
      error = e
    end

    error
  end
end

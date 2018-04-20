require 'uri'

module RestfulResourceBugsnag
  class Middleware
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(notification)
      exception = notification.exceptions.first

      if exception.is_a?(RestfulResource::HttpClient::HttpError)
        notification.add_tab(:restful_resource_response, {
          status: exception.response.status,
          body: exception.response.body,
          headers: exception.response.headers
        })
        notification.add_tab(:restful_resource_request, {
          method: exception.request.method,
          url: exception.request.url,
          body: exception.request.body
        })
      end

      # Display the request host in the context so its easy to see in Bugsnag which service was unresponsive
      # Group the errors by host to reduce the amount of error spam
      if exception.is_a?(RestfulResource::HttpClient::ServiceUnavailable)
        notification.context = "HTTP 503: Service unavailable #{request_host_from_exception exception}"
        notification.grouping_hash = notification.context
      end

      if exception.is_a?(RestfulResource::HttpClient::ClientError)
        notification.context = "Client error: Service unavailable #{request_host_from_exception exception}"
        notification.grouping_hash = notification.context
      end
      
      if exception.is_a?(RestfulResource::HttpClient::Timeout)
        notification.context = "Client error: Timeout #{request_host_from_exception exception}"
        notification.grouping_hash = notification.context
      end

      @bugsnag.call(notification)
    end

    private

    def request_host_from_exception(exception)
      URI.parse(exception.request.url).host
    end
  end
end

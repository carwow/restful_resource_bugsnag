module RestfulResourceBugsnag
  class Middleware
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(notification)
      exception = notification.exceptions.first

      if exception.is_a?(RestfulResource::HttpClient::HttpError)
        notification.add_tab(:response, {
          status: exception.response.status,
          body: exception.response.body,
          headers: exception.response.headers
        })
        notification.add_tab(:request, {
          method: exception.request.method,
          url: exception.request.url,
          accept: exception.request.accept,
          body: exception.request.body
        })
      end
      @bugsnag.call(notification)
    end
  end
end

module RestfulResourceBugsnag
  class Middleware
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(notification)
      exception = notification.exceptions.first

      if exception.is_a?(RestfulResource::HttpClient::UnprocessableEntity) ||
          exception.is_a?(RestfulResource::HttpClient::OtherHttpError)
        notification.add_tab(:response, {
          status: exception.response.status,
          body: exception.response.body,
          headers: exception.response.headers
        })
      end
      @bugsnag.call(notification)
    end
  end
end

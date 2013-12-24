module Rack; module Throttle
  ###
  # UrlMatchers are used to restrict requests based on the URL
  # requested. For instance, you may care about limiting requests
  # to a machine-consumed API, but not be concerned about requests
  # coming from browsers.
  # UrlMatchers take Regexp object to matcha gainst the request path.
  class ExcludeUrlMatcher < Matcher
    ###
    # @param [Rack::Request] request
    # @return [Boolean]
    def match?(request)
      !(request.path =~ @rule)
    end

    ###
    # @return [String]
    def identifier
      "url-" + @rule.inspect
    end
  end

end; end


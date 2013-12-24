require 'rack'

module Rack
  module Throttle
    autoload :Limiter,          'rack/throttle/limiters/limiter'
    autoload :Interval,         'rack/throttle/limiters/interval'
    autoload :TimeWindow,       'rack/throttle/limiters/time_window'
    autoload :Daily,            'rack/throttle/limiters/daily'
    autoload :Hourly,           'rack/throttle/limiters/hourly'
    autoload :SlidingWindow,    'rack/throttle/limiters/sliding_window'
    autoload :VERSION,          'rack/throttle/version'
    autoload :Matcher,          'rack/throttle/matchers/matcher'
    autoload :UrlMatcher,       'rack/throttle/matchers/url_matcher'
    autoload :ExcludeUrlMatcher,'rack/throttle/matchers/exclude_url_matcher'
    autoload :MethodMatcher,    'rack/throttle/matchers/method_matcher'
    autoload :UserAgentMatcher, 'rack/throttle/matchers/user_agent_matcher'
  end
end

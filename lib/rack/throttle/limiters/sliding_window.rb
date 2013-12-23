module Rack; module Throttle
  ##
  # This rate limiter strategy throttles the application with
  # a sliding window (implemented as a leaky bucket). It operates
  # on second-level resolution. It takes :burst and :average 
  # options, which correspond to the maximum size of a traffic 
  # burst, and the maximum allowed average traffic level.
  class SlidingWindow < Limiter
    ##
    # @param  [#call]                    app
    # @param  [Hash{Symbol => Object}]   options
    # @option options [Integer] :burst   5
    # @option options [Float] :average   1
    def initialize(app, options = {})
      super
      options[:burst] ||= 5
      options[:average] ||= 1
    end

    ##
    # Returns `true` if the request conforms to the 
    # specified :average and :burst rules
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    def allowed?(request)
      t1 = request_start_time(request)
      key = cache_key(request)
      begin
        bucket_info_str = cache_get(key).to_s
        ary = bucket_info_str.split(',')
        bucket_count = ary[0].to_i
        time_number = ary[1].to_f
      rescue
        bucket_count = 0
        time_number = Time.now.to_f
      end
      bucket = LeakyBucket.new(options[:burst], options[:average], bucket_count, time_number)
      #bucket.maximum, bucket.outflow = options[:burst], options[:average]
      bucket.leak!
      bucket.increment!
      allowed = !bucket.full?
      begin
        cache_set(key, bucket)
        allowed
      rescue StandardError => e
        allowed = true
        # If an error occurred while trying to update the timestamp stored
        # in the cache, we will fall back to allowing the request through.
        # This prevents the Rack application blowing up merely due to a
        # backend cache server (Memcached, Redis, etc.) being offline.
      end
    end

    ###
    # LeakyBucket is an internal class used to implement the
    # SlidingWindow limiter strategy. It is a (slightly tweaked)
    # implementation of the {http://en.wikipedia.org/wiki/Leaky_bucket
    # Leaky Bucket Algorithm}.
    class LeakyBucket
      attr_accessor :maximum, :outflow
      attr_reader :count, :last_touched

      ##
      # @param [Integer] maximum
      # @param [Float] outflow
      def initialize(maximum, outflow, count, time_number)
        @maximum, @outflow = maximum, outflow
        @count, @last_touched = count, Time.at(time_number)
      end

      def leak!
        t = Time.now
        time_elapsed = t - last_touched
        loss = (outflow * time_elapsed).floor
        if loss > 0
          @count -= loss
          @last_touched = t
        end
      end

      def increment!
        @count = 0 if count < 0
        @count += 1
        @count = maximum if count > maximum
      end

      def to_s
        [count, @last_touched.to_f].join(',')
      end

      def full?
        count == maximum
      end
    end

  end
end; end

module Remotipart

  # A middleware to look for our form parameters and
  # encourage Rails to respond with the requested format
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      # Get request params
      begin
        params = Rack::Request.new(env).params
      rescue TypeError => e
        ::Rails.logger.warn e.message
        ::Rails.logger.warn e.backtrace.join("\n")
      end

      if params
        if params['X-Requested-With'] == 'IFrame' || env['HTTP_X_REQUESTED_WITH'] == 'FormData'
          params['remotipart_submitted'] = params['X-Requested-With'] || env['HTTP_X_REQUESTED_WITH']
          # This was using a custom transport, and is therefore an XHR
          # This is required if we're going to override the http_accept
          env['HTTP_X_REQUESTED_WITH'] = 'xmlhttprequest'
        end

        # For iFrame transport, override the accepted format, because it isn't what we really want
        if params['X-Http-Accept']
          env['HTTP_ACCEPT'] = params['X-Http-Accept']
        end
      end

      @app.call(env)
    end
  end
end

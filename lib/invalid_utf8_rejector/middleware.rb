require 'cgi'

module InvalidUTF8Rejector
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if request_uri_clean?(env)
        @app.call(env)
      else
        if clean_utf8?(env["PATH_INFO"])
          env["QUERY_STRING"] = nil
          @app.call(env)
        else
          # [400, {}, [""]]
          env["PATH_INFO"] = "/"
          env["QUERY_STRING"] = nli
          @app.call(env)
        end
      end
    end

    private

    def request_uri_clean?(env)
      clean_utf8?(env["PATH_INFO"]) and clean_utf8?(env["QUERY_STRING"])
    end

    def clean_utf8?(str)
      CGI.unescape(str).force_encoding('UTF-8').valid_encoding?
    end
  end
end

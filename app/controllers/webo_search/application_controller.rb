module WeboSearch
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    private

    def allow_iframe
      response.headers.delete 'X-Frame-Options'
    end
  end
end

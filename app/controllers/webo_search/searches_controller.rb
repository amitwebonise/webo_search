module WeboSearch
  class SearchesController < ApplicationController
    layout :false
    before_action :extract_namespace
    after_action :allow_iframe, only: :show

    def show
      if @webo_search.has_key?('primary_model')
        @results = WeboSearch.results(params) if params.has_key?('search')
      else
        Rails.logger.info('Please check webo_search.yml for proper configuration !!!')
        redirect_to :back, alert: 'You cannot access this URL !!!'
      end
    end

    def extract_namespace
      @webo_search = WeboSearch.configure
      if params[:namespace].present? && @webo_search.has_key?(params[:namespace])
        @webo_search['primary_model'] = @webo_search["#{params[:namespace]}"]['primary_model']
        @webo_search['associated_model'] = @webo_search["#{params[:namespace]}"]['associated_model']
      end
    end

    private

    def allow_iframe
      response.headers.delete 'X-Frame-Options'
    end
  end
end

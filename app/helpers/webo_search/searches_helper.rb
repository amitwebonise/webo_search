module WeboSearch
  module SearchesHelper

    def states_with_all
      @states.unshift(['All', 'Ignore'])
    end
  end
end

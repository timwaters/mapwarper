module Api
  module V1
    class MapsController < ApiController

      def index
        maps = Map.all.limit(2)
        render :json => maps
      end
  
    end
  end
end

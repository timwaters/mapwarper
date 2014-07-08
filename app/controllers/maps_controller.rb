class MapsController < ApplicationController


  # GET /posts
  # GET /posts.json
  def index
    @maps = Map.all
  end

end

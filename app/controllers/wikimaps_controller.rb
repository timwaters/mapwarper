class WikimapsController < ApplicationController
  require 'digest/md5'
  before_filter :authenticate_user! , :except => [:new]
  #skip_before_filter :verify_authenticity_token

  def new
    @html_title = "New wikimaps map "
    if params[:path]
      image_url = URI.escape("https:"+ params[:path])
      @image_title = File.basename(image_url)

      if map = Map.find_by_unique_id(@image_title)

        if map.warped_or_published?
          redirect_to map_path(:id => map, :anchor => "Preview_Map_tab")
        elsif user_signed_in?
          redirect_to map_path(:id => map, :anchor => "Rectify_tab")
        else
          redirect_to map
        end
      end
    end

  end

  def create
    image_url = URI.escape("https:"+ params[:path])
    image_title = File.basename(image_url)

    if map = Map.find_by_unique_id(image_title)
      redirect_to map
      return
    end

    map = {
      :title => image_title,
      :unique_id => image_title,
      :public => true,
      :map_type => "is_map",
      :upload_url => image_url
    }

    @map = Map.new(map)

    if user_signed_in?
      @map.owner = current_user
      @map.users << current_user
    end

    respond_to do |format|
      if @map.save
        flash[:notice] = 'Map was successfully created.'
        format.html { redirect_to map_path(@map.id) }
      else
        flash[:error] = "Map not created. Error message:<br />"+ @map.errors.to_a.join(" ")
        format.html{ redirect_to :action => "new" }
      end
    end


  end

end


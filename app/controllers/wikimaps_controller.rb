class WikimapsController < ApplicationController
  require 'digest/md5'
  require 'open-uri'
  before_filter :authenticate_user!, except: [:new]
  # skip_before_filter :verify_authenticity_token

  def new
    @html_title = 'New wikimaps map '
    
    if params[:pageid] && !params[:pageid].blank?
      unless params[:pageid] =~ /\A\d+\Z/
        flash[:notice] = "No map added - page id should be a number"
        redirect_to maps_path
        return
      end
      site = APP_CONFIG["omniauth_mediawiki_site"]
      url = URI.encode(site + '/w/api.php?action=query&prop=imageinfo&iiprop=url|mime&iiurlwidth=100&format=json&pageids=' + params[:pageid])
      data = URI.parse(url).read
      json = ActiveSupport::JSON.decode(data)
      
      if json['query']['pages']["#{params[:pageid]}"]['imageinfo'].nil?
        flash[:notice] = "No image found for that wiki page ID"
        redirect_to maps_path 
        return 
      end
      image_url = json['query']['pages']["#{params[:pageid]}"]['imageinfo'][0]['url']
      @image_title = json['query']['pages']["#{params[:pageid]}"]['title']
      unique_id = File.basename(json['query']['pages']["#{params[:pageid]}"]['imageinfo'][0]['url'])
      page_id = params[:pageid]
      
      mime = json['query']['pages']["#{params[:pageid]}"]['imageinfo'][0]['mime']
      thumb_url = json['query']['pages']["#{params[:pageid]}"]['imageinfo'][0]['thumburl']
      
      @thumbnail_url = thumb_url
      
      if mime == "image/tiff"
        @thumbnail_url = thumb_url.sub(/page1-100px/, "page1-300px")
      else
        @thumbnail_url = thumb_url.sub(/\/100px/, "/300px")
      end
      
      session[:user_return_to] = request.url unless user_signed_in?

      if map = Map.find_by_page_id(page_id) || Map.find_by_unique_id(unique_id)

        if map.warped_or_published?
          redirect_to map_path(id: map, anchor: 'Preview_tab')
        elsif user_signed_in?
          redirect_to map_path(id: map, anchor: 'Rectify_tab')
        else
          redirect_to map
        end
      end

    else
      redirect_to maps_path
    end
  
  end

  def create
    if params[:pageid] && !params[:pageid].blank?

      unless params[:pageid] =~ /\A\d+\Z/
        flash[:notice] = "No map added - page id should be a number"
        redirect_to maps_path
        return
      end

      @map = Map.new_from_wiki(params[:pageid])

    end

    if existing_map = Map.find_by_page_id(@map.page_id) || Map.find_by_unique_id(@map.title)
      redirect_to existing_map
      return
    end

    if user_signed_in?
      @map.owner = current_user
      @map.users << current_user
    end

    respond_to do |format|
      if @map.save
        flash[:notice] = 'Map was successfully created.'
        format.html { redirect_to map_path(@map.id) }
      else
        flash[:error] = 'Map not created. Error message:<br />' + @map.errors.to_a.join(' ')
        format.html { render action: 'new' }
      end
    end
  end
end

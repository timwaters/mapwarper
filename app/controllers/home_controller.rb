class HomeController < ApplicationController

  layout 'application'
  
  def index
    @html_title =  "Home - "

#   #@tags  = Tag.counts(:limit => 60)
    @tags = Map.where(:public => true).tag_counts(:limit => 100)
    @maps = Map.where(:public => true, :status => [2,3,4]).order(:updated_at =>  :desc).limit(3).includes(:gcps)
#
#    @layers = Layer.find(:all,:order => "updated_at DESC", :limit => 3, :include=> :maps)
#    get_news_feeds
#
#    if logged_in?
#      @my_maps = current_user.maps.find(:all, :order => "updated_at DESC", :limit => 3)
#    end
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @maps }
#    end
  end



end

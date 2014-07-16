class HomeController < ApplicationController

  layout 'application'
  
  def index
    @html_title =  "Home - "

#    #@tags  = Tag.counts(:limit => 60)
#    @tags = Map.tag_counts(:conditions => "public = true", :limit=>100)
#    @maps = Map.public.find(:all,
#      :order => "updated_at DESC",
#      :conditions => 'status = 4 OR status IN (2,3,4) ', 
#      :limit => 3, :include =>:gcps)
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

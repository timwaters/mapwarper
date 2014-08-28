class HomeController < ApplicationController

  layout 'application'
  
  def index
    @html_title =  "Home - "

    @tags = Map.where(:public => true).tag_counts(:limit => 100)
    @maps = Map.where(:public => true, :status => [2,3,4]).order(:updated_at =>  :desc).limit(3).includes(:gcps)
    
    @layers = Layer.all.order(:updated_at => :desc).limit(3).includes(:maps)
    
    if user_signed_in?
      @my_maps = nil
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maps }
    end
  end

  private
  
  def get_news_feeds
    cache("news_feeds", :expires_in => 1.day.from_now) do 
      logger.info "getting news feed"
      @feeds = RssParser.run("http://thinkwhere.wordpress.com/tag/mapwarper/feed/")
      @feeds = @feeds[:items][0..1]
    end
  end


end

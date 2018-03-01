class HomeController < ApplicationController

  layout 'application'
  
  def index
    @html_title =  t('.title')

    @tags = Map.where(:public => true).tag_counts(:limit => 100)
    @maps = Map.where(:public => true, :status => [2,3,4]).order(:updated_at =>  :desc).limit(3).includes(:gcps)
    
    @layers = Layer.all.order(:updated_at => :desc).limit(3).includes(:maps)

    @year_min = Map.minimum(:issue_year).to_i - 1
    @year_max = Map.maximum(:issue_year).to_i + 1
    @year_min = 1500 if @year_min == -1
    @year_max = Time.now.year if @year_max == 1

    #get_news_feeds
    
    if user_signed_in?
      @my_maps = current_user.maps.order(:updated_at => :desc).limit(3)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maps }
    end
  end
  
  # Searches for Maps and Layers across the titles and descriptions
  # Returns json (using jbuilder)
  # params 
  # query : string to search
  # per_page : limit number of records (optional)
  def search
    per_page = params[:per_page] || 50
    logger.debug per_page
    @results = PgSearch.multisearch(params[:query].to_s).limit(per_page.to_i)
  end
  
  private
  
  def get_news_feeds
    @feeds = Rails.cache.fetch("mapwarper_news", :expires_in => 1.day.from_now) do 
      feeds = RssParser.run("https://thinkwhere.wordpress.com/tag/mapwarper/feed/")
      feeds[:items][0..2]
    end
  end


end

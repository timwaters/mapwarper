class HomeController < ApplicationController

  layout 'application'
  
  def index
    @html_title =  t('.title')

    @tags = Map.where(:public => true).tag_counts(:limit => 100)
    @maps = Map.where(:public => true, :status => [2,3,4]).order(:updated_at =>  :desc).limit(3).includes(:gcps)
    
    @layers = Layer.all.order(:updated_at => :desc).limit(3).includes(:maps)

    @year_min = Map.minimum(:issue_year).to_i - 1
    @year_max = Map.maximum(:issue_year).to_i + 1
    @year_min = 1600 if @year_min == -1
    @year_max = Time.now.year if @year_max == 1

    get_news_feeds
    
    if user_signed_in?
      @my_maps = current_user.maps.order(:updated_at => :desc).limit(3)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maps }
    end
  end

  private
  
  def get_news_feeds
    cache("news_feeds", :expires_in => 1.day.from_now) do 
      @feeds = RssParser.run("https://thinkwhere.wordpress.com/tag/mapwarper/feed/")
      @feeds = @feeds[:items][0..1]
    end
  end


end

class HomeController < ApplicationController

  layout 'application'
  def index
    @html_title =  "Home - "

    #@tags  = Tag.counts(:limit => 60)
    @tags = Map.tag_counts(:conditions => "public = true", :limit=>100)
    @maps = Map.public.find(:all,
                             :order => "updated_at DESC",
                             :conditions => 'status = 4 OR status IN (2,3,4) ', 
                             :limit => 3, :include =>:gcps)

    @layers = Layer.find(:all,:order => "updated_at DESC", :limit => 3, :include=> :maps)
    get_news_feeds

    if logged_in?
      @my_maps = current_user.maps.find(:all, :order => "updated_at DESC", :limit => 3)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maps }
    end
  end



  def get_news_feeds
  when_fragment_expired 'news_feeds', 1.day.from_now do
    logger.info "getting news feed"
    @feeds = RssParser.run("http://thinkwhere.wordpress.com/tag/mapwarper/feed/")
    @feeds = @feeds[:items][0..1]
  end
end



end

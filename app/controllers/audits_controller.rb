class AuditsController < ApplicationController
  layout "application"

  def show
    @audit  = Activity.find(params[:id])
  end

  def index
    @html_title = "Recent Activity"
    @audits = Activity.paginate(:page => params[:page],
      :per_page => 20,
      :order => "created_at DESC")
    @title = "Recent Activity For Everything"
    @linktomap = "yes please"
    render :action => 'index'
  end



  def for_user
    @user = User.find(params[:id])
    @html_title = "Activity for " + @user.login.capitalize

    @audits = Activity.paginate(:page => params[:page],
      :per_page => 20,
      :order => "created_at DESC",
      :conditions => ['user_id = ?', params[:id] ])
    @title = "Recent Activity for User " +@user.login.capitalize
    render :action => 'index'
  end

  def for_map
    @selected_tab = 5
    @current_tab = "activity"
    @map = Map.find(params[:id])
    @html_title = "Activity for Map " + @map.id.to_s
    @audits = Activity.paginate(:page => params[:page],
      :per_page => 20,
      :order => "created_at DESC",
      :conditions => ['auditable_type = ? AND auditable_id = ?',
        'Map', @map.id])
    @title = "Recent Activity for Map "+params[:id].to_s
    respond_to do | format |
      if request.xhr?
        @xhr_flag = "xhr"
        format.html { render  :layout => 'tab_container' }
      else
        format.html {render :layout => 'mapdetail'}
      end
      format.rss {render :action=> 'index'}
    end
  end

  def for_map_model
    @html_title = "Activity for All Maps"

    @audits = Activity.paginate(:page => params[:page],
      :per_page => 20,
      :conditions => ['auditable_type = ?', 'Map'],
      :order => 'created_at DESC')

    @title = "Recent Activity for All Maps"
    render :action => 'index'
  end

end

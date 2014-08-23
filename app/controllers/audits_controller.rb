class AuditsController < ApplicationController
  layout "application"

  def show
    @audit  = Audited::Adapters::ActiveRecord::Audit.find(params[:id])
  end

  def index
    @html_title = "Recent Activity"
    @audits = Audited::Adapters::ActiveRecord::Audit.unscoped.order(:created_at => :desc).paginate(:page => params[:page],
      :per_page => 20)
    @title = "Recent Activity For Everything"
    @linktomap = "yes please"
    render :action => 'index'
  end



  def for_user
    user_id = params[:id].to_i
    @user = User.where(id: user_id).first
    if @user
      @html_title = "Activity for " + @user.login.capitalize
      @title = "Recent Activity for User " +@user.login.capitalize
    else
      @html_title = "Activity for not found user #{params[:id]}"
      @title = "Recent Activity for not found user #{params[:id]}"
    end
    
    
    
    order_options = "created_at DESC"
    where_options = ['user_id = ?', user_id ]
    @audits = Audited::Adapters::ActiveRecord::Audit.unscoped.where(where_options).order(order_options).paginate(:page => params[:page],
      :per_page => 20)
      
    render :action => 'index'
  end

  def for_map
    @selected_tab = 5
    @current_tab = "activity"
    @map = Map.find(params[:id])
    @html_title = "Activity for Map " + @map.id.to_s
    
    order_options = "created_at DESC"
    where_options = ['auditable_type = ? AND auditable_id = ?', 'Map', @map.id]
    @audits = Audited::Adapters::ActiveRecord::Audit.unscoped.where(where_options).order(order_options).paginate(:page => params[:page], :per_page => 20)

    @title = "Recent Activity for Map "+params[:id].to_s
    respond_to do | format |
      if request.xhr?
        @xhr_flag = "xhr"
        format.html { render  :layout => 'tab_container' }
      else
        format.html {render :layout => 'application' }
      end
      format.rss {render :action=> 'index'}
    end
  end

  def for_map_model
    @html_title = "Activity for All Maps"
    order_options = "created_at DESC"
    where_options = ['auditable_type = ?', 'Map']
    @audits = Audited::Adapters::ActiveRecord::Audit.unscoped.where(where_options).order(order_options).paginate(:page => params[:page], :per_page => 20)

    @title = "Recent Activity for All Maps"
    render :action => 'index'
  end

end

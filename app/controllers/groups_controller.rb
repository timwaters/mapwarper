class GroupsController < ApplicationController

  before_filter :find_group, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required, :except => [:index]
  before_filter :check_administrator_role, :only => [ :create, :edit, :update, :destroy]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record
  #TODO add comments 

  helper :sort
  include SortHelper


  def index
    @html_title = "Browse Groups"
    sort_init 'id'
    sort_update
    @query = params[:query]
    @field = %w(name description).detect{|f| f == (params[:field])}
    if @query && @query.strip.length > 0 && @field
      conditions = ["#{@field}  ~* ?", '(:punct:|^|)'+@query+'([^A-z]|$)']
    else
      conditions = nil
    end

    @groups = Group.paginate(:page => params[:page],:per_page => 20, :order => "updated_at DESC",  :conditions => conditions, :include => :groups_maps)
  end


  def show
    @group_maps = @group.maps.paginate(:page => params[:page], :per_page => 10, :order => "groups_maps.created_at DESC")
    @group_users = @group.users.paginate(:page => params[:page], :per_page => 100, :order => "memberships.created_at DESC")
    @html_title = "Showing Group " + @group.id.to_s
  end


  def new
    @group = Group.new
  end


  def create
    @group = Group.new(params[:group])
    @group.creator = current_user
    if @group.save
      flash[:notice] = "New Group Created!"
      redirect_to group_url(@group)
    else
      render :action => 'new'
    end
  end


  def edit

  end


  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = "Successfully updated group."
      redirect_to group_url(@group)
    else
      render :action => 'edit'
    end
  end


  def destroy
  # if (group.creator == current_user) or admin_authorized?
      if @group.destroy
        flash[:notice] = "Group deleted!"
      else
        flash[:notice] = "Group couldn't be deleted."
      end
      
    redirect_to groups_path
  end


  private

  def find_group
    @group = Group.find(params[:id])
  end


  def bad_record
    #logger.error("not found #{params[:id]}")
    respond_to do | format |
      format.html do
        flash[:notice] = "Group not found"
        redirect_to :root
      end
      format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
    end
  end


end

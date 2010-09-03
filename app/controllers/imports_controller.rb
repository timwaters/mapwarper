class ImportsController < ApplicationController
  #status
  #client polls this to check on status of import
  #such like 1/200 images imported
  before_filter :login_required
  before_filter :check_administrator_role
  before_filter :find_import, :except => [:index, :new, :create]

  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record

  def index
    @imports = Import.paginate(:page => params[:page],:per_page => 30, :order => "updated_at DESC")
  end

  def new
    @import = Import.new
    @import.uploader_user_id = current_user.id
  end

  def create
    @import = Import.new(params[:import])
    @import.user = current_user
    @import.state = "ready"
    if @import.save
      flash[:notice] = "New Import Created!"
      redirect_to import_url(@import)
    else
      render :action => 'new'
    end
  end


  def edit

    @import.user = current_user
    @import.state = "ready"
  end

  def show

  end

  def destroy

    if @import .destroy
      flash[:notice] = "Import deleted!"
    else
      flash[:notice] = "Import couldn't be deleted."
    end

    redirect_to imports_path
  end
 
  def update
    @import.map_count = 12
    if @import.update_attributes(params[:import])

      flash[:notice] = "Successfully updated import."
      redirect_to import_url(@import)
    else
      render :action => 'edit'
    end
  end

  def start
    #starts import, shows message saying it is importing
    #spawn do
    #end
    @import.start_importing
    render :text => @import.status_message
  end

  def status
    render :text => @import.status_message
  end

  def finished
    #show finished import, or alter show?
  end

  private
  def find_import
    @import = Import.find(params[:id])
  end

  def bad_record
    respond_to do | format |
      format.html do
        flash[:notice] = "Import not found"
        redirect_to :root
      end
      format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
    end
  end

end
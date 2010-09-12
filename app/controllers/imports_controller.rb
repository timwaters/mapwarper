class ImportsController < ApplicationController
  #status
  #client polls this to check on status of import
  #such like 1/200 images imported
  before_filter :login_required
  before_filter :check_administrator_role
  before_filter :find_import, :except => [:index, :new, :create]
  before_filter :check_imported, :only => [:start]

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
      flash[:error] = "Something went wrong creating the import"
      render :action => 'new'
    end
  end


  def edit
  end

  def show
  end

  def destroy
    if @import.destroy
      flash[:notice] = "Import deleted!"
    else
      flash[:notice] = "Import couldn't be deleted."
    end
    redirect_to imports_path
  end
 
  def update
    if @import.update_attributes(params[:import])
      flash[:notice] = "Successfully updated import."
      redirect_to import_url(@import)
    else
      flash[:error] = "Something went wrong updating the import"
      render :action => 'edit'
    end
  end

  def start
    spawn do
      @import.start_importing
    end
  end

  def status
    render :text => @import.status
  end

  def maps
    @upload_user = User.find(@import.uploader_user_id)
    if @import.layer_id == -99
      @layer = @import.maps.first.layers.first
    elsif @import.layer_id != nil
      @layer = Layer.find(@import.layer_id)
    end
    

    #show finished import, or alter show?
  end

  private
  
  def find_import
    @import = Import.find(params[:id])
  end

  def check_imported
    if @import.state == "imported"
      flash[:notice] = "Sorry, can't be done, this import has already been imported."
      redirect_to imports_path
    end
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
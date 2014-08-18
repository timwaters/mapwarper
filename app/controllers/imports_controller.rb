class ImportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :check_administrator_role

  before_filter :find_import, :except => [:index, :new, :create]
  before_filter :check_imported, :only => [:start]

  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record

  def index
    @imports = Import.order("updated_at DESC").paginate(:page => params[:page],:per_page => 30)
  end

  def new
    @import = Import.new
    @import.uploader_user_id = current_user.id
  end

  def create
    @import = Import.new(import_params)
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
    if @import.update_attributes(import_params)
      flash[:notice] = "Successfully updated import."
      redirect_to import_url(@import)
    else
      flash[:error] = "Something went wrong updating the import"
      render :action => 'edit'
    end
  end

  def start
    Spawnling.new do
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
  
  def import_params
      params.require(:import).permit(:name,:path, :map_title_suffix, :map_description, :map_publisher, :map_author, :layer_id, :layer_title,  :uploader_user_id, 
        :maps_attributes => [:title, :description, :publisher, :authors, :source_uri, :id, "_destroy"] )
  end

end

class AnnotationsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :find_annotation, :only => [:show, :update, :destroy]
  before_filter :check_administrator_role, :only =>  [:destroy]

  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record

  helper :sort
  include SortHelper

  def index
    sort_init 'created_at'
    sort_update

    if params[:map_id]
      @map = Map.find(params[:map_id])
    end

    if current_user.has_role?('administrator')

      @query = params[:query]
    
      if @query && @query.strip.length > 0
        conditions = ["body  ~* ?", '(:punct:|^|)'+@query+'([^A-z]|$)']
      else
        conditions = nil
      end
      if @map
        map_conditions = {map: @map}
      else
        map_conditions = nil
      end
      
      @annotations = Annotation.where(conditions).where(map_conditions).order(sort_clause).paginate(:page=> params[:page], :per_page => 50)

    #  @annotations = Annotation.all
    elsif  @map
      @annotations = Annotation.where(:map => @map).paginate(:page=> params[:page], :per_page => 50)
    end

    respond_to do | format |
      format.html {}
      format.json {render :json => @annotations, :status => :ok }
    end

  end

  def show
    render :json => @annotation, :status => :ok
  end

  def create
    @annotation = Annotation.new(annotation_params)
    @annotation.user = current_user

    if @annotation.save
      render :json => @annotation, :status => :ok
    else
      render :json => @annotation, :status => :unprocessable_entity
    end

  end

  def update
    if @annotation.update(annotation_params.except(:map_id))
      flash[:notice] = t('.flash')
      render :json => @annotation, :status => :ok
    else
      flash[:error] = t('.error')
      render :json => @annotation, :status => :unprocessable_entity
    end
  end

  def destroy
    if @annotation.destroy
      flash[:notice] = t('.notice')
    else
      flash[:error] = t('.error')
    end
    
    if params[:return] == "map"
      redirect_to map_path(:id => @annotation.map.id, :anchor=>"Annotate_tab")
    else
      redirect_to :action => 'index'
    end
  end

  private

  def find_annotation
    @annotation  = Annotation.find(params[:id])
  end

  def annotation_params
    params.permit(:body, :geom, :map_id) 
  end

  def bad_record
    respond_to do | format |
      format.html do
        flash[:notice] = "Annotation not found"
        redirect_to :annotations
      end
      format.json {render :json => {:stat => "not found", :items =>[]}.to_json, :status => 404}
    end
  end

end

# annotation GET    /annotations/:id(.:format)                     annotations#show
# PATCH  /annotations/:id(.:format)                     annotations#update
# PUT    /annotations/:id(.:format)                     annotations#update
# DELETE /annotations/:id(.:format)                     annotations#destroy

class AnnotationsController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!
  before_filter :find_annotation, :only => [:show, :update, :destroy]
  before_filter :check_administrator_role, :only =>  [:destroy]

  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record

  helper :sort
  include SortHelper

  #main public search
  def search
    sort_init 'created_at'
    sort_update

    @field = "annotation"

    @year_min = Map.minimum(:issue_year).to_i - 1
    @year_max = Map.maximum(:issue_year).to_i + 1
    @year_min = 1500 if @year_min == -1
    @year_max = Time.now.year if @year_max == 1

    if params[:map_id]
      @map = Map.find(params[:map_id])
    end

    @query = params[:query]

    if @map
      map_conditions = {map: @map}
    else
      map_conditions = nil
    end
    
    @annotations = Annotation.body_search(@query).where(map_conditions).with_pg_search_highlight.order(sort_clause).paginate(:page=> params[:page], :per_page => 50)

  end


  def index
    sort_init 'created_at'
    sort_update

    if params[:map_id]
      @map = Map.find(params[:map_id])
    end

    @query = params[:query]

    if @map
      map_conditions = {map: @map}
    else
      map_conditions = nil
    end

    paginate_options = {
      :page => params[:page],
      :per_page => params[:per_page] || 50
    }
    
    unless @query && @query.strip.length > 0
      @annotations = Annotation.where(nil).where(map_conditions).order(sort_clause).paginate(paginate_options)
    else
      @annotations = Annotation.body_search(@query).where(map_conditions).with_pg_search_highlight.with_pg_search_rank.unscope(:order).order(sort_clause).paginate(paginate_options)
    end

    respond_to do | format |
      format.html {}
      format.json {render :json => @annotations, :status => :ok }
      format.csv {}
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
      flash.now[:notice] = t('.notice')
      render :json => @annotation, :status => :ok
    else
      flash.now[:error] = t('.error')
      render :json => @annotation, :status => :unprocessable_entity
    end
  end

  def destroy
    if @annotation.destroy
      flash.now[:notice] = t('.notice')
    else
      flash.now[:error] = t('.error')
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

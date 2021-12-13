class Api::V1::AnnotationsController < Api::V1::ApiController
  before_filter :authenticate_user!
  before_filter :validate_jsonapi_type,    :only =>  [:create, :update]
  before_filter :find_annotation,          :only =>  [:show, :update, :destroy]
  before_filter :check_administrator_role, :only =>  [:destroy]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_param_error

  def show
    render :json => @annotation
  end

  def create
    @annotation = Annotation.new(annotation_params)
    @annotation.user = current_user

    if @annotation.save
      render :json => @annotation, :status => :created
    else
      render :json => @annotation, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end

  def update
    if @annotation.update(annotation_params.except(:map_id))
      render :json => @annotation, :status => :ok
    else
      render :json => @annotation, :status => :unprocessable_entity, :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end

  def destroy
    if @annotation.destroy
      render :json => @annotation
    else
      render :json => @annotation, :status => :unprocessable_entity,  :serializer => ActiveModel::Serializer::ErrorSerializer 
    end
  end

  def index

    sort_order = "desc"
    sort_order = "asc" if index_params[:sort_order] == "asc"
    sort_key = %w(map_id created_at updated_at lat lon x y).detect{|f| f == (index_params[:sort_key])}
    sort_key = sort_key || "updated_at" if sort_order == "desc"
    sort_clause = "#{sort_key} #{sort_order}"

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

    render :json => @annotations, :meta => {
      "total_entries" => @annotations.total_entries,
      "total_pages"   => @annotations.total_pages}
  end

  private

  def annotation_params
    params.require(:data).require(:attributes).permit(:body, :geom, :map_id)
  end
  

  def index_params
    params.permit(:page, :per_page, :query, :field, :sort_key, :sort_order, :field,  :format, :map_id)
  end

  def find_annotation
    @annotation = Annotation.find(params[:id])
  end
  
  
end
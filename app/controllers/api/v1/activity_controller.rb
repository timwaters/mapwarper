class Api::V1::ActivityController < Api::V1::ApiController
  before_filter :authenticate_user!
  before_filter :check_administrator_role, :only => [:stats]
  
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    
  def stats
    sort_order = "desc"
    sort_order = "asc" if params[:sort_order] == "asc"
    sort_key = %w(total_count map_count gcp_count gcp_update_count gcp_create_count gcp_destroy_count username user_id).detect{|f| f == (params[:sort_key])}
    sort_key = sort_key || "total_count" if sort_order == "desc"
  
    order_options = "#{sort_key} #{sort_order}"

    the_sql = "select user_id, username, COUNT(user_id) as total_count,
      COUNT(case when auditable_type='Gcp' then 1 end) as gcp_count,
      COUNT(case when auditable_type='Map' or auditable_type='Mapscan' then 1 end) as map_count,
      COUNT(case when action='update' and auditable_type='Gcp' then 1 end) as gcp_update_count,
      COUNT(case when action='create' and auditable_type='Gcp' then 1 end) as gcp_create_count,
      COUNT(case when action='destroy' and auditable_type='Gcp' then 1 end) as gcp_destroy_count
      from audits group by user_id, username ORDER BY #{order_options}"

    audits = Audited::Adapters::ActiveRecord::Audit.paginate_by_sql(the_sql, paginate_options)
    render_json(audits)
  end
  
  def index
    order_options = "created_at DESC"
    audits = get_audits(nil, order_options)
    
    render_json(audits)
  end
  
  def map_index
    order_options = "created_at DESC"
    where_options = ['auditable_type = ?', 'Map']
    audits = get_audits(where_options, order_options)

    render_json(audits)
  end
  
  def for_map
    map = Map.find(params[:id])
 
    order_options = "created_at DESC"
    where_options = ['auditable_type = ? AND auditable_id = ?', 'Map', map.id]
    audits = get_audits(where_options, order_options)
    
    render_json(audits)
  end
  
  def for_user
    user_id = params[:id].to_i
    user = User.find_by_id(user_id)

    order_options = "created_at DESC"
    where_options = ['user_id = ?', user.id ]
    audits = get_audits(where_options, order_options)
    
    render_json(audits)
  end

  private
  
  def paginate_options
    {
      :page => params[:page],
      :per_page => params[:per_page] || 50
    }
  end
  
  def get_audits(where_options, order_options)
    select = "id, auditable_id, auditable_type, user_id, action, version, created_at"  #"audited_changes"
    Audited::Adapters::ActiveRecord::Audit.unscoped.select(select).where(where_options).order(order_options).paginate(paginate_options)
  end
  
  def render_json(audits)
    render :json => {:data => audits, :meta => {"total_entries" => audits.total_entries, "total_pages" => audits.total_pages} }, :adapter => :json
  end
  
end 


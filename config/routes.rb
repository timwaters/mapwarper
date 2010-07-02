ActionController::Routing::Routes.draw do |map|

  map.root :controller => "home", :action => "index"
  
  map.user_activity '/users/:id/activity', :controller => 'audits', :action => 'for_user'
  map.formatted_user_activity '/users/:id/activity.:format', :controller => 'audits', :action => 'for_user'

  map.maps_activity '/maps/activity', :controller => 'audits', :action => 'for_map_model'
  map.formatted_maps_activity  '/maps/activity.:format', :controller => 'audits', :action => 'for_map_model'
  map.map_activity '/maps/:id/activity', :controller => 'audits', :action => 'for_map'
  map.formatted_map_activity '/maps/:id/activity.:format', :controller => 'audits', :action => 'for_map'

  map.activity '/activity', :controller => 'audits'
  map.formatted_activity '/activity.:format', :controller => 'audits'
  map.activity_details '/activity/:id', :controller => 'audits',:action => 'show'


  map.connect '/maps/activity', :controller => 'audits', :action => 'for_map_model'

  map.connect '/gcps/:id', :controller => 'gcp', :action=> 'show'
  map.connect '/gcps/show/:id', :controller=> 'gcp', :action=>'show'

  map.my_maps '/users/:user_id/maps', :controller => 'my_maps', :action => 'list'

  map.add_my_map '/users/:user_id/maps/create/:map_id', :controller => 'my_maps', :action => 'create', :conditions => { :method => :post }
  map.destroy_my_map '/users/:user_id/maps/destroy/:map_id', :controller => 'my_maps', :action => 'destroy', :conditions => { :method => :post}



  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resend_activation '/resend_activation', :controller => 'users', :action => 'resend_activation'
  map.force_resend_activation '/force_resend_activation/:id', :controller => 'users', :action => 'force_resend_activation'
  map.activate '/activate/:id', :controller => 'user_accounts', :action => 'show'
  map.change_password '/change_password',   :controller => 'user_accounts', :action => 'edit'
  map.forgot_password '/forgot_password',   :controller => 'passwords', :action => 'new'
  map.reset_password '/reset_password/:id', :controller => 'passwords', :action => 'edit'
  # map.resources :users, :has_many => :user_maps,
  map.force_activate '/force_activate/:id', :controller => 'users', :action => 'force_activate', :conditions =>{:method => :put}
  map.disable_and_reset '/disable_and_reset/:id', :controller => 'users', :action => 'disable_and_reset', :conditions => {:method => :put}
  map.resources :users, :member => {:enable => :put, :disable => :put } do |users|
    users.resource :user_account
    users.resources :roles
  end

  map.resource :session
  map.resource :password
  #end authentication route stuff

  #nicer paths for often used map paths
  map.warp_map '/maps/warp/:id', :controller => 'maps', :action => 'warp'
  map.clip_map '/maps/crop/:id', :controller => 'maps', :action => 'clip'
  map.align_map '/maps/align/:id', :controller => 'maps', :action => 'align'
  map.warped_map '/maps/preview/:id', :controller => 'maps', :action => 'warped'
  map.export_map '/maps/export/:id', :controller => 'maps', :action => 'export'
  map.map_status '/maps/status/:id', :controller => 'maps', :action => 'status'
  map.metadata_map '/maps/metadata/:id', :controller => 'maps', :action => 'metadata'
  map.export_map '/maps/export/:id', :controller => 'maps', :action => 'export'
  map.formatted_export_map '/maps/export/:id.:format', :controller => 'maps', :action => 'export'
  map.wms_map '/maps/wms/:id', :controller => 'maps', :action => 'wms'

  map.map_tag '/maps/tag/:id', :controller => 'maps', :action => 'tag', :requirements => { :id => %r([^/;,?]+) }

  map.connect '/layers/wms2', :controller => 'layers', :action => 'wms2'
  map.resources :maps  do |a |
    a.resources :layers
  end
  map.resources :layers

  map.digitize_layer '/layers/digitize/:id', :controller => 'layers', :action => 'digitize'
  map.export_layer '/layers/export/:id', :controller => 'layers', :action => 'export'
  map.metadata_layer '/layers/metadata/:id', :controller => 'layers', :action => 'metadata'

  map.connect 'digitize/subtype.:format', :controller => 'digitize', :action=> 'subtype'


  # The priority is based upon order of creation: first created -> highest priority.


  #for legacy urls
  #map.connect '/mapscans/*', :controller => 'maps'
  #map.connect '/mapscans/:id', :controller => 'maps', :action => "show"
  #map.connect '/mapscans/:action/:id', :controller => 'maps'
  #map.connect '/mapscans/:action/:id.:format', :controller => 'maps'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  #map.connect '', :controller => "maps"
  map.connect '', :controller => "home"
  #for legacy urls
  #map.connect '/mapscans/:action/:id', :controller => 'maps'
end

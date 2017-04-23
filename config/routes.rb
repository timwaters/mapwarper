Rails.application.routes.draw do
  root 'home#index'
  get '/about' => 'home#about', :as => 'about'
  get '/help' => 'home#help', :as => 'help'
  
  devise_for :users, :path => 'u',:controllers => { :sessions => "sessions", :omniauth_callbacks => "omniauth_callbacks" }
  
  resources :users do
    member do
      put 'enable'
      put 'disable'
      put 'disable_and_reset'
      put 'force_confirm'
    end
    collection do
      get 'stats'
    end
    resource :user_account
    resources :roles
  end
  
  get '/maps/activity' => 'audits#for_map_model', :as => "maps_activity"
  
  resources :maps  do
    member do
      post 'map_type'
      get 'export'
      get 'warp'
      get 'clip'
      post 'rectify'
      get 'align'
      get 'warped'
      get 'metadata'
      get 'comments'
      get 'delete'
      get 'status'
      get 'publish'
      get 'unpublish'
      post 'save_mask_and_warp'
      delete 'delete_mask'
      post 'warp_aligned'
      get 'gcps'
      get 'rough_state' => 'maps#get_rough_state'
      post 'rough_state' => 'maps#set_rough_state'
      get 'rough_centroid'=> 'maps#get_rough_centroid'
      post 'rough_centroid' => 'maps#set_rough_centroid'
      get 'id'
      get 'trace'
      get 'idland'
    end
    collection do
        get 'geosearch'
        get 'tag'
        get 'csv'
    end
    resources :layers
  end
  
  get '/maps/tag/:query' => 'maps#tag', :as => "map_tag"
  
  get '/mapimages/:id.gml.ol' => 'maps#get_mask', :as => "masking_map"
  get '/maps/thumb/:id' => 'maps#thumb', :as =>'thumb_map'
  get '/maps/thumb' => 'maps#thumb', :as => 'map_thumb_base'
  get '/layers/thumb' => 'layers#thumb', :as => 'layer_thumb_base'
  get '/mosaics/thumb/:id' => 'layers#thumb', :as =>'thumb_layer'
  get '/layers/thumb/:id' => 'layers#thumb'
 
  
  #get '/gcps/' => 'gcps#index', :as => "gcps"
  get '/gcps/bulk_import' => 'gcps#bulk_import', :as => "bulk_import_gcps"
  get '/gcps/csv' => 'gcps#csv', :as =>'csv_gcps'
  get '/gcps/:id' => 'gcps#show', :as => "gcp"
  delete '/gcps/:id/destroy' => 'gcps#destroy', :as => "destroy_gcp"
  post '/gcps/add/:mapid' => 'gcps#add', :as => "add_gcp"
  put '/gcps/update/:id' => 'gcps#update', :as => "update_gcp"
  put '/gcps/update_field/:id' => 'gcps#update_field', :as => "update_field_gcp"
  
  
  post '/gcps/add_many' => 'gcps#add_many', :as => 'add_many_gcps'
  post '/gcps/add_many/:mapid' => 'gcps#add_many_to_map', :as => 'add_many_gcps_to_map'

  get '/maps/wms/:id' => "maps#wms", :as => 'wms_map'
  get '/maps/tile/:id/:z/:x/:y' => "maps#tile", :as => 'tile_map'
  get '/maps/tile/:id' => "maps#tile", :as => 'tile_map_base'
  
  get '/mosaics/wms/:id' => "layers#wms", :as => "wms_layer"
  get '/mosaics/wms' => "layers#wms", :as => "wms_layer_base"
  get '/mosaics/tile/:id/:z/:x/:y' => "layers#tile", :as => 'tile_layer'
  get '/mosaics/tile/:id' => "layers#tile", :as => 'tile_layer_base'
 
  get '/layers/wms/:id' => "layers#wms"
  get '/layers/wms' => "layers#wms"
  get '/layers/tile/:id/:z/:x/:y' => "layers#tile"
  get '/layers/tile/:id' => "layers#tile"

  resources :layers do
    member do
      get 'comments'
      get 'merge'
      get 'publish'
      get 'toggle_visibility'
      patch 'update_year'
      get 'wms'
      get 'wms2'
      get 'maps'
      get 'export'
      get 'metadata'
      get 'delete'
      get 'id'
      get 'trace'
      get 'idland'
    end
    collection do 
      get 'geosearch'
    end
  end
  
  put '/layers/:id/remove_map/:map_id' => 'layers#remove_map', :as => 'remove_layer_map'
  put '/layers/:id/merge' => 'layers#merge', :as => 'do_merge_layer'
  
  get '/users/:user_id/maps' => 'my_maps#list', :as => 'my_maps'
  post '/users/:user_id/maps/create/:map_id' => 'my_maps#create', :as => 'add_my_map'
  post '/users/:user_id/maps/destroy/:map_id' => 'my_maps#destroy', :as => 'destroy_my_map'

  get '/users/:id/activity' => 'audits#for_user', :as => 'user_activity'
  
  
  get '/maps/acitvity.:format' => 'audits#for_map_model', :as => "formatted_maps_activity"
  get '/maps/:id/activity' => 'audits#for_map', :as => "map_activity"
  get '/maps/:id/activity.:format' => 'audits#for_map', :as => "formatted_map_activity"

  get '/activity' => 'audits#index', :as => "activity"
  get '/activity/:id' => 'audits#show', :as => "activity_details"
  get '/activity.:format' => 'audits#index', :as => "formatted_activity"

  
  resources :comments

  
  resources :groups 
  
  get '/groups/:group_id/users/new' => 'memberships#new', :as => 'new_group_user'
  delete '/groups/:group_id/users/destroy/:id' => 'memberships#destroy', :as => 'destroy_group_user'
  get '/groups/:group_id/users' => 'users#index_for_group', :as => 'group_users'
  get '/groups/:group_id/map' => 'maps#index_for_map', :as => 'group_maps'

  resources :imports do
    member do
      get 'maps'
      get 'start'
      get 'status'
      get 'log'
    end
  end
  
  get 'exports' => 'imports#exports'
  
  get '/search' => 'home#search', :as => 'search'
   
  namespace :api do
    namespace :v1 do
      get '/' =>  'api#index'
      constraints defaults: {format: "json"} do
        resources :maps, :except => [:new] do
          member do
            get    'gcps'
            patch  'rectify'
            post   'mask'
            delete 'mask'   => 'maps#delete_mask'
            patch  'crop'   
            patch  'mask_crop_rectify'
            patch  'publish'
            patch  'unpublish'
            get    'status'
          end
          resources :layers, :only => [:index]
        end
  
        resources :layers, :except => [:new] do
          member do
            patch 'toggle_visibility'
            patch 'remove_map'
            patch 'merge'
          end
          collection do
          end
          resources :maps, :only => [:index]
        end
        
      end
      constraints  defaults: {format: "json"} do
        
        resources :gcps, :except => [:new] do
          collection do
            post 'add_many'
          end
        end
        
        resources :users, :only => [:show, :index]

# imports disabled for mapwarper.net (and they need a bit of updating too)
#        resources :imports, :except => [:new] do
#          member do
#            patch 'start'
#            get   'maps'
#          end
#        end
        
        #stats and activity
        get 'stats' =>              'activity#stats'
        get 'activity' =>           'activity#index'
        get 'activity/maps' =>      'activity#map_index'
        get 'activity/users/:id' => 'activity#for_user'
        get 'activity/maps/:id' =>  'activity#for_map'
        get 'activity/:id' =>       'activity#show'
        
        #token / auth etc
        #api/v1/auth/sign_in etc
        devise_scope :user do
          get    'auth/validate_token' => 'sessions#validate_token'
          post   'auth/sign_in'        => 'sessions#create'
          delete 'auth/sign_out'       => 'sessions#destroy'
        end
        
      end
    end
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

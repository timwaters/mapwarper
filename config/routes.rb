Rails.application.routes.draw do
  root 'home#index'
  get '/about' => 'home#about', :as => 'about'
  get '/help' => 'home#help', :as => 'help'
  
  devise_for :users
  
  resources :users do
    member do
      put 'enable'
      put 'disable'
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
      get 'map_type'
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
    end
    collection do
        get 'geosearch'
        get 'tag'
    end
    resources :layers
  end
  
  get '/maps/thumb/:id' => 'maps#thumb', :as =>'thumb_map'
  
  get '/gcps/' => 'gcp#index', :as => "gcps"
  get '/gcps/:id' => 'gcps#show', :as => "gcp"
  delete '/gcps/:id/destroy' => 'gcps#destroy', :as => "destroy_gcp"
  post '/gcps/add/:mapid' => 'gcps#add', :as => "add_gcp"
  put '/gcps/update/:id' => 'gcps#update', :as => "update_gcp"
  put '/gcps/update_field/:id' => 'gcps#update_field', :as => "update_field_gcp"
  

  get '/maps/wms/:id' => "maps#wms", :as => 'wms_map'
  get '/maps/tile/:id/:z/:x/:y' => "maps#tile", :as => 'tile_map'
  
  resources :layers do
    member do
      get 'comments'
      get 'merge'
      get 'publish'
      get 'toggle_visibility'
      get 'wms'
    end
    collection do 
      get 'geosearch'
    end
  end
  
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
  #get '/maps/:id/comments' => 'maps#comments', :as => "comments_map"
 # get '/layers/:id/comments' => 'layers#comments', :as => "comments_layer"

  
  resources :groups 
  
  resources :imports do
    member do
      get 'maps'
      get 'start'
      get 'status'
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

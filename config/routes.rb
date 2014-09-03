Rails.application.routes.draw do

  resources :milestones do
    collection do
      get 'lookup'
      post 'lookup'
      get 'file_upload'
      post 'import_file'
    end
  end


  get "login/login"

  get "login/logout"
  post "login/logout"
  post "login/login"

  resources :inventory_projections do
    collection do
      get 'lookup'
      post 'lookup'
      get 'file_upload'
      post 'import_file'
    end
  end

  resources :scv_exceptions do
    collection do
      get 'file_upload'
      post 'import_file'
    end
  end


  resources :shipment_lines do
    collection do
      get 'lookup'
      post 'lookup'
      get 'file_upload'
      post 'import_file'
    end
  end

  resources :order_lines do
    collection do
      get 'lookup'
      post 'lookup'
      get 'file_upload'
      post 'import_file'
    end 
  end

  resources :location_groups

  resources :locations

  resources :products do
    collection do
      get 'lookup'
      post 'lookup'
    end
  end

  resources :users do
    member do
      get 'reset_password'
    end
  end


  resources :organizations

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

  controller :dashboard do
    get 'dashboard', action: "index"
  end


  root to: 'dashboard#index'

end

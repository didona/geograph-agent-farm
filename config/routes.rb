###############################################################################
###############################################################################
#
# This file is part of GeoGraph Agent Farm.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph Agent Farm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph Agent Farm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph Agent Farm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################

GeographGenerator::Application.routes.draw do
  #match 'commands', :to => 'commands#execute', :via => [:post]
  match 'console', :to => 'farm#console', :via => :get, :as => :console

  resources :agent_groups, :id => /.+/ do
    member do
      post 'start'
      post 'stop'
      post 'pause'
    end
  end

  resources :dynamic_profiles do
  end

  resources :benchmark_schedules do
    collection do
      post 'set_benchmark'
      put 'play'
      put 'stop'
      delete 'remove_profile'
      put 'sort'
      get 'progress'
      put 'update_iterations'
      put 'update_profile_iterations'
    end
  end

  #resources :farm do
  #  member do
  #    post 'choose_process'
  #  end
  #end

  resources :agents do
    collection do
      get "refresh_time"
    end
  end

  resources :static_profiles do
    member do
      get 'edit_groups'
      put 'update_groups'
      get 'new_group'
      delete 'destroy_group'
    end

    collection do
      post 'create_with_group'
      put 'sort'
    end
  end

  match 'update_profile' => "farm#update_profile"
  match 'delete_profile' => "farm#delete_profile"
  match 'create_benchmark' => "dynamic_profiles#create"
  match 'set_properties' => "farm#choose_process"
  match 'map' => "farm#map"
  devise_for :users, :path_prefix => 'my'
  resources :users

  mount Madmass::Engine => '/madmass', :as => 'madmass_engine'

  root :to => 'farm#console'

  match 'benchmark' => "benchmark_schedules#index"
  #match 'add_workload'=> "benchmark_schedules#add_workload"
  

  match 'map_url'=> "settings#map"
  match 'stats_url'=> "settings#stats"

  match 'stats' => "farm#stats"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

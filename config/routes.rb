JqueryVoting::Application.routes.draw do

  namespace "admin" do
    resources :base, :only => :index
    resources :members do
      resources :memberships do
        member do
          get :terminate
        end
      end
    end
    resources :tags
  end
  get "/admin", :to => "admin/base#index"

  devise_for :members do
    get "sign_in", :to => "devise/sessions#new"
    get "sign_out", :to => "devise/sessions#destroy"
  end

  resources :motions do
    resources :events, :controller => :motion_events
    post 'second',  :to => 'motion_events#second'
    post 'object',  :to => 'motion_events#object'
    post 'vote',    :to => 'motion_events#vote'

    collection do
      get :closed
      get :show_more
    end
  end

  post "/taggings/:tag_id/:motion_id"   => 'taggings#create',  :as => 'add_tag'
  delete "/taggings/:tag_id/:motion_id" => 'taggings#destroy', :as => 'remove_tag'

  root :to => "motions#index"
end

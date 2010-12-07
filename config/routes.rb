JqueryVoting::Application.routes.draw do

  namespace "admin" do
    resources :members
  end

  devise_for :members do
    get "sign_in", :to => "devise/sessions#new"
    get "sign_out", :to => "devise/sessions#destroy"
  end

  resources :motions do
    resources :events, :controller => :motion_events
    collection do
      get :closed
      get :show_more
    end
  end

  root :to => "welcome#index"
end

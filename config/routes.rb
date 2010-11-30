JqueryVoting::Application.routes.draw do
  devise_for :members do
    get "sign_in", :to => "devise/sessions#new"
    get "sign_out", :to => "devise/sessions#destroy"
  end

  resources :motions

  
  root :to => "welcome#index"

  if Rails.env.cucumber?
    match '/sessions_backdoor/:email' => 'sessions#backdoor'
  end
end

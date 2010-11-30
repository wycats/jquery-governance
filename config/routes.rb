JqueryVoting::Application.routes.draw do
  devise_for :members

  root :to => "welcome#index"

  if Rails.env.cucumber?
    match '/sessions_backdoor/:email' => 'sessions#backdoor'
  end
end

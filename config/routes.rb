JqueryVoting::Application.routes.draw do
  devise_for :members

  root :to => "welcome#index"
end

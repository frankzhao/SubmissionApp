SubmissionApp::Application.routes.draw do
  resource :sessions

  resources :courses

  root :to => 'courses#index'
end

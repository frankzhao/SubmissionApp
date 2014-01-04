SubmissionApp::Application.routes.draw do
  # get "groups/show"

  # get "group/show"

  resource :sessions, :only => [:new, :create, :destroy]

  resources :courses, :only => [:index, :show]
  resources :users, :only => [:show]

  resources :group_types, :only => [:show]

  resources :groups, :only => [:show]

  resources :assignments, :only => [:show] do
    resources :assignment_submissions do
      resources :comments, :only => [:create, :delete]
    end
  end

  get 'assignments/:id/marks.csv', :to => 'assignments#get_csv',
                                   :as => 'assignment_marks'

  root :to => 'courses#index'
end

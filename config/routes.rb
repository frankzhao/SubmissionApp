SubmissionApp::Application.routes.draw do
  # get "groups/show"

  # get "group/show"

  resource :sessions, :only => [:new, :create, :destroy]

  resources :courses, :only => [:index, :show] do
    resources :users, :only => [:new, :create]
  end

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

  get 'assignments/:assignment_id/assignment_submissions/:id/file.zip',
                                    :to => 'assignment_submissions#get_zip',
                                    :as => 'assignment_submission_zip'

  root :to => 'courses#index'
end

SubmissionApp::Application.routes.draw do
  # get "groups/show"

  # get "group/show"

  resource :sessions, :only => [:new, :create, :destroy]

  resources :courses, :only => [:new, :create, :index, :show, :destroy] do
    resources :users, :only => [:new, :create]
  end

  resources :users, :only => [:show]

  resources :group_types, :only => [:show] do
    resources :assignments, :only => [:new]
  end

  resources :groups, :only => [:show]

  resources :assignments, :only => [:show, :create, :destroy, :edit, :update] do
    resources :assignment_submissions do
      resources :comments, :only => [:create, :destroy]
    end
  end

  get 'assignments/:id/marks.csv', :to => 'assignments#get_csv',
                                   :as => 'assignment_marks'

  get 'assignments/:id/submissions.zip', :to => 'assignments#get_zipfile',
                                         :as => 'assignment_zipfile'

  post 'assignments/:id/peer_review', :to => 'assignments#peer_review',
                                      :as => 'assignment_peer_review'

  get 'assignments/:assignment_id/assignment_submissions/:id/file.zip',
                                    :to => 'assignment_submissions#get_zip',
                                    :as => 'assignment_submission_zip'

  root :to => 'courses#index'
end

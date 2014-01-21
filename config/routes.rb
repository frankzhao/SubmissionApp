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

    get 'cycles', :to => 'peer_review_cycles#index', :as => "cycles"
    post 'cycles', :to => 'peer_review_cycles#create'
    put 'cycles/:id/edit', :to => 'peer_review_cycles#update'
    #TODO: this is an ugly hack and should be fixed
    post 'cycles/:id', :to => 'peer_review_cycles#delete', :as => "cycles_delete"
    get 'cycles/:id/edit', :to => 'peer_review_cycles#edit', :as => "cycles_edit"
    post 'cycles/:id/activate', :to => 'peer_review_cycles#activate',
                                :as => "cycle_activate"
    post 'cycles/:id/deactivate', :to => 'peer_review_cycles#deactivate',
                                :as => "cycle_deactivate"
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

SubmissionApp::Application.routes.draw do
  # get "groups/show"

  # get "group/show"

  resource :sessions, :only => [:new, :create, :destroy]

  resources :courses, :only => [:new, :create, :index, :show, :destroy] do
    resources :users, :only => [:new, :create]
    resources :student_enrollments, :only => [:create, :destroy]
  end

  resources :users, :only => [:show]

  resources :group_types do
    resources :assignments, :only => [:new]
    resources :groups, :only => [:create]
    post 'csv', :to => 'groups#edit_by_csv', :as => 'edit_by_csv'
  end

  resources :groups, :only => [:show]

  resources :assignments, :only => [:show, :create, :destroy, :edit, :update] do
    resources :assignment_submissions, :except => [:update, :edit, :destroy] do
      resources :comments, :only => [:create, :destroy]
    end

    get 'cycles', :to => 'peer_review_cycles#index', :as => "cycles"
    post 'cycles', :to => 'peer_review_cycles#create'
    put 'cycles/:id/edit', :to => 'peer_review_cycles#update'
    delete 'cycles/:id', :to => 'peer_review_cycles#delete', :as => "cycles_delete"
    get 'cycles/:id/edit', :to => 'peer_review_cycles#edit', :as => "cycles_edit"
    post 'cycles/:id/activate', :to => 'peer_review_cycles#activate',
                                :as => "cycle_activate"
    post 'cycles/:id/deactivate', :to => 'peer_review_cycles#deactivate',
                                :as => "cycle_deactivate"

    resources :marking_categories, :only => [:create, :destroy, :update, :index]
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

  get 'comment_files/:id', :to => 'comments#get_file',
                           :as => 'comment_file'

  root :to => 'courses#index'
end

SubmissionApp::Application.routes.draw do
  # get "groups/show"

  # get "group/show"

  resource :sessions, :only => [:new, :create, :destroy]

  resources :courses, :only => [:new, :create, :index, :show, :destroy] do
    resources :users, :only => [:new, :create]
    resources :student_enrollments, :only => [:create, :destroy]
  end

  resources :users, :only => [:show, :index, :destroy]

  resources :group_types do
    resources :assignments, :only => [:new]
    resources :groups, :only => [:create]
    post 'csv', :to => 'group_types#edit_by_csv', :as => 'edit_by_csv'
  end

  resources :groups, :only => [:show]

  resources :assignments, :only => [:show, :create, :destroy, :edit, :update] do
    resources :assignment_submissions, :except => [:update, :edit] do
      resources :comments, :only => [:create, :destroy]
      post 'finalize', :to => 'assignment_submissions#finalize',
                       :as => "finalize"
      get 'printable', :to => 'assignment_submissions#printable',
                        :as => "printable"
    end

    get 'groups/:id', :to => 'groups#assignment_show', :as => 'group_show'

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

    resources :extensions, :only => [:index, :create]
  end

  resources :extensions, :only => [:destroy]

  resources :notifications, :only => [:destroy, :index]

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

  get 'admin/log', :to => 'admin#log'
  get 'admin/summary_log', :to => 'admin#summary_log'
  get 'admin/database', :to => 'admin#database'
  get 'admin/spoof-login/:id', :to => 'admin#spoof_login'
  get 'admin/charts', :to => 'admin#charts'

  get 'files/:id', :to => 'submission_files#serve', :as => 'file_serve'
end

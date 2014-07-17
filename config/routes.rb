Rails.application.routes.draw do
  resources :subject_has_classifications
  resources :subject_heading_types do
    resources :subjects
  end
  resources :subject_types
  resources :subjects do
    resources :works, :controller => 'manifestations'
    resources :subject_heading_types
    resources :subject_has_classifications
    resources :work_has_subjects
    resources :classifications
  end
  resources :subject_heading_type_has_subjects

  match 'subjects/search_name' => 'subjects#search_name'

  match 'classifications/search_name' => 'classifications#search_name'
  resources :classifications do
    resources :subject_has_classifications
  end
  resources :classification_types do
    resource :classifications
  end

  resources :work_has_subjects

end

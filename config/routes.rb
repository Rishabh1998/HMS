Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'admin/dashboard#index'

  namespace :admin do
    resources :permissions do
      collection do
        post :reload
      end
    end
  end

end

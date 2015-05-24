Rails.application.routes.draw do
  constraints(subdomain: "manage") do
    resources :songs, only: [:new, :create, :edit, :update, :destroy], controller: "manage/songs" do
      collection do
        put :publish
      end
    end

    root to: "manage/songs#index", as: "manage_root"
  end

  resources :songs, only: [:show]

  root to: "songs#index"
end

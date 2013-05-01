Ships::Application.routes.draw do
  resources :game
  root :to => 'game#index'
  match 'tablet' => 'game#tablet'
end

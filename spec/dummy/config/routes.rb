# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  get '/login' => 'login#new', as: 'login'

  namespace :admin do
    resources :events
    resources :locations
    resources :series
    resources :bookings
  end

  mount Alchemy::Engine => "/"
end

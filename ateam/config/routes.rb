Rails.application.routes.draw do
  resources :posts
  resources :stat_lists
  resources :game_stats
  resources :games 
  
  devise_for :users, :controllers => {:registrations => "registrations"}

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'pages#index'

  get 'landing' => 'landing#index'
  get 'about'=> 'pages#about'
  get 'tutorial' => 'pages#tutorial'
  get 'admin' => 'admin#index', as: :admin
  get 'admin/mailer' => 'admin#mailer'
  post 'admin/send_mail' => 'admin#send_mail'

  get 'get_team_stats/:season_id' => 'pages#get_team_stats'




  get 'product' => 'product#index'
  get 'product/play_diagramming' => 'product#play_diagramming', as: :product_play_diagramming
  get 'product/stat_collection' => 'product#stat_collection', as: :product_stat_collection
  get 'product/analytics' => 'product#analytics', as: :product_analytics
  get 'product/team_hub' => 'product#team_hub', as: :product_team_hub



  get 'demos' => 'demos#index', as: :demos

  post 'seeding_endpoint' => 'pages#seeding_endpoint'

  post "/api/generate_checkout_new_url" => "chargebee#checkout_new"
  post "/api/commit_new_customer" => "chargebee#commit_new_customer"

  post 'create_portal_session' => 'chargebee#portal_session_new'
  post 'cancel_subscription' => 'chargebee#cancel_subscription'
  post 'reactivate_subscription' => 'chargebee#reactivate_subscription'
  post 'retrieve_subscription' => 'chargebee#retrieve_subscription'

  post 'test_webhook' => 'chargebee#test_webhook'

  get 'nba_api' => 'pages#nba_api'

  get 'heat_map' => 'pages#heat_map'

  get 'reset_db' => 'pages#reset'

  get 'no_access' => 'pages#no_access', as: :no_access

  get 'demos/plays' => 'demos#plays', as: :play_demo

  get 'demos/game_mode' => 'demos#game_mode', as: :game_mode_demo

  get 'demos/analytics' => 'demos#analytics', as: :stats_demo

  get 'add_team' => 'teams#new'

  get 'get_seasons' => 'users#get_seasons'
  post '/verify_email_unique' => 'users#verify_email_unique'
  post '/make_user_admin/:user_id' => 'users#make_user_admin'
  delete '/destroy_user/:user_id' => 'users#destroy_user'

  get '/teams/:team_id/seasons/:season_id/new' => 'seasons#new', as: :new_season
  post '/teams/:team_id/seasons/:season_id/create' => 'seasons#create'

  get '/teams/:team_id/seasons/:season_id/j/:member_id' => 'seasons#join'
  post '/teams/:team_id/seasons/:season_id/join_season' => 'seasons#join_season'
  post '/join_season' => 'seasons#join_season_alt'
 
 # post '/teams/:team_id/plays/new' => "plays#new"

  post '/teams/:team_id/seasons/:season_id/plays/new_play' => "plays#new_play"

  post '/teams/:team_id/seasons/:season_id/plays/:play_id/soft_delete' => "plays#soft_delete"
  post '/teams/:team_id/seasons/:season_id/plays/:play_id/recover' => "plays#recover"
  post '/teams/:team_id/seasons/:season_id/plays/delete_all' => "plays#destroy_all"
  post '/teams/:team_id/seasons/:season_id/plays/recover_all' => "plays#recover_all"
  patch '/teams/:team_id/seasons/:season_id/plays/:play_id/update_name' => "plays#update_name"

  get '/teams/:team_id/seasons/:season_id/stats/trend_data' => 'stats#trend_data'

  get '/teams/:team_id/seasons/:season_id/shot_chart_data' => 'stats#shot_chart_data'

  get '/teams/:team_id/seasons/:season_id/load_more_lineups' => 'stats#load_more_lineups'

  get '/teams/:team_id/seasons/:season_id/stats/player_profile/:member_id' => 'stats#player_profile'

  post '/teams/:team_id/seasons/:season_id/playlists/:playlist/delete_association' => "playlists#delete_association"

  post '/teams/:team_id/seasons/:season_id/plays/:play_id/blank_progression' => 'progressions#blank_progression'

  post '/plays/:play_id/seasons/:season_id/progressions/next(.:format)' => 'progressions#create_next'

  get '/teams/:team_id/seasons/:season_id/games/:id/game_mode(.:format)' => 'games#game_mode', as: :game_mode

  get '/teams/:team_id/seasons/:season_id/games/:id/game_preview(.:format)' => 'games#game_preview', as: :game_preview

  get '/teams/:team_id/practices/:id/practice_mode(.:format)' => 'practices#practice_mode', as: :practice_mode

  get '/teams/:team_id/scrimmage_mode(.:format)' => 'practices#scrimmage_mode', as: :scrimmage_mode

  post '/teams/:team_id/seasons/:season_id/games/:id/game_state_update(.:format)' => 'games#game_state_update'

  post '/teams/:team_id/practices/:id/scrimmage_mode_submit' => 'practices#scrimmage_mode_submit'

  post '/teams/:team_id/seasons/:season_id/games/:id/game_mode(.:format)' => 'games#game_mode_submit'

  post '/teams/:team_id/lineup_explorer' => "teams#create_lineup"

  post '/teams/:team_id/seasons/:season_id/settings(.:format)' => "settings#update"

  get 'test_home' => 'pages#test_home'

  post '/teams/:team_id/seasons/:season_id/posts/:post_id/comment(.:format)' => "posts#create_comment"

  post '/notifications' => "notifications#viewed"
  post '/notification_read' => "notifications#read"
  get '/notifications' => "notifications#get", as: :get_notifications
  get '/load_more_notifications' => "notifications#load_more_notifications", as: :load_more_notifications
  
  post '/plays/:play_id/progressions/remove_progression_notification(.:format)' => 'progressions#remove_progression_notification'

  get 'messenger', to: 'messengers#index'
  get 'get_private_conversation', to: 'messengers#get_private_conversation'
  get 'get_group_conversation', to: 'messengers#get_group_conversation'
  get 'open_messenger', to: 'messengers#open_messenger'

  post '/teams/:team_id/join_team' => "teams#join_member"

  resources :plays do
    resources :progressions
  end 

  namespace :private do 
    resources :conversations, only: [:create] do
      member do
        post :close
        post :open
      end
    end
    resources :messages, only: [:index, :create]
  end

  namespace :group do 
    resources :conversations do
      member do
        post :close
        post :open
      end
    end
    resources :messages, only: [:index, :create]
  end

  authenticate :user do
    resources :teams do 
        resources :seasons do 
          resources :team_stats do 
          end
          resources :practices do 
          end
          resources :stats do
          end
          resources :games do 
          end
          resources :plays do 
            resources :progressions 
          end
          resources :settings do
          end
        end
    end
  end

  resources :teams do 
    resources :seasons do 
      resources :plays do 
        resources :progressions 
      end
      resources :team_stats do 
      end
      resources :stats do
      end
      resources :games do 
      end
      resources :settings do
      end
      resources :playlists do 
      end
      resources :posts do 
      end
    end
  end


  post 'join_team' => 'teams#join'

  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
  end

  devise_scope :user do
    get 'signup', to: 'devise/registrations#new'
  end

  devise_scope :user do 
     post 'send_password_email' => 'passwords#send_password_email'
  end 
  
end

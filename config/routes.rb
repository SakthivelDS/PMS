Rails.application.routes.draw do
  
  resources :authusers
  resources :payments
  resources :user_details, except: [:index]
  
  post "payments/:id/approve_payment", to: "payments#approve_payment", as: "approve_payment_show"
  post "payments/:id/user_approve", to: "payments#approve_payment_user", as: "approve_payment_by_user" 
  
  get "user_details/:id/getRequests", to: "user_details#get_requests", as: "myrequests"

  root to: "application#rootredirect"
  get "authuser/signin", to: "authusers#signin", as: "auth_signin"
  get "authuser/signup", to: "authusers#signup", as: "auth_signup"

  post "authuser/signin", to: "sessions#create", as: "auth_signin_submit"
  post "authuser/signup/authenticate", to: "authusers#signup_authenticate", as: "auth_signup_submit"
  post "authuser/destroy", to: "sessions#destroy", as: "session_destroy"  

  post "authuser/approve/:id", to: "authusers#approve_user", as: "approve_user"
  post "authuser/reject/:id", to: "authusers#reject_user", as: "reject_user"

  post "sessions", to: "sessions#create", as: "create_session"

  get "*path", to: "application#invalid_redirect"

end

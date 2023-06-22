class SessionsController < ApplicationController
    before_action :require_user, except: [:create]

    def create
          
        if !params[:authuser] || !params[:authuser][:username] || !params[:authuser][:password] || params[:authuser][:username].length == 0 || params[:authuser][:password].length == 0
            flash[:alert] = "Fill all the fields"
            redirect_to auth_signin_path 
        else 
            user = Authuser.find_by(username: (params[:authuser][:username]).downcase)
            if user && user.authenticate(params[:authuser][:password])
                if !user.approved
                    flash[:alert] = "Your account is not yet approved.."
                    redirect_to auth_signin_path
                else
                    userid = UserDetail.find_by(username: user.username)
                    session[:user_id] = userid.id 
                    flash[:notice] = "Logged in"
                    
                    redirect_to user_detail_path(userid)
                end
            else 
                flash[:alert] = "Invalid credentials"
                redirect_to auth_signin_path
            end
        end
    end
    def destroy
        session[:user_id] = nil
        flash[:notice] = "Logged out successfully.."
        redirect_to auth_signin_path
    end
end
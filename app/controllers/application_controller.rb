class ApplicationController < ActionController::Base


    helper_method :current_user, :loggedin?, :require_user

    def invalid_redirect
         rootredirect
    end

    def rootredirect
        if loggedin?
            redirect_to user_detail_path(current_user)
        else
            redirect_to auth_signin_path 
        end
    end

    def index
        
    end

    def current_user
        if session[:user_id]
            @current_user ||= UserDetail.find(session[:user_id])
        end
    end

    def loggedin?
        !!current_user
    end

    def require_user
        if !loggedin?
            flash[:alert] = "You must login before continue.."
            redirect_to auth_signin_path
        end
    end

    def require_admin
        if !current_user.admin
            flash[:alert] = "You are not an admin.."
            redirect_to user_detail_path(current_user)
        end
    end
end 

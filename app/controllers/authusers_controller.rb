class AuthusersController < ApplicationController
  before_action :require_user, except: [ :signup, :signup_authenticate, :signin, :home]
  before_action :require_admin, only: [:approve_user, :reject_user, :index]
  before_action :set_authuser, only: %i[ show edit update destroy ]
  
  def home

  end

  def signin
    @authuser = Authuser.new
  end

  # def signin_authenticate
  #   username = authuser_signin_params[:username]
  #   pass = authuser_signin_params[:password]
    
  #   if username.length == 0 || pass.length == 0
  #     flash[:alert]  = "Enter all the fields.."
  #     redirect_to auth_signin_path
    
  #   elsif @authuser = Authuser.find_by(username: username) || @authuser = UserDetail.find_by(username: username)
      
  #     if @authuser.authenticate(pass)
  #       if @authuser.approved
  #         render 'sessions/create', params: {user_id: @authuser.id}
          
  #       else
  #         flash[:alert] = "Your account is not yet approved.."
  #         redirect_to auth_signin_path
  #       end
  #     else 
  #       flash[:alert] = "Invalid credentials.."
  #       redirect_to auth_signin_path
  #     end
  #   else
  #     flash[:alert] = "Invalid credentials"
  #     redirect_to auth_signin_path
  #   end
  # end

  def signup
    @authuser = Authuser.new
  end

  def signup_authenticate
    @authuser = Authuser.new(authuser_params)
    
    @authuser.username = @authuser.username.downcase
    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    if !(@authuser.email =~ email_regex)
      flash.now[:alert] = "Invalid Email"
      render "signup"
    elsif !@authuser.username || !@authuser.email || !@authuser.password
      flash.now[:alert] = "Fill all the fields"
      render "signup"
    elsif Authuser.find_by(username: @authuser.username)
      flash.now[:alert] = "Username already exists.."
      render 'signup'
    elsif Authuser.find_by(email: @authuser.email) || UserDetail.find_by(email: @authuser.email)
      flash.now[:alert] = "Email already exists.."
      render 'signup'
    elsif @authuser.save
      flash[:notice] = "Account created.."
      redirect_to auth_signin_path
    else
      flash.now[:alert] = "Some error"
      render 'signup'
    end
  end 

  def approve_user
    authuser_id = params[:id]
    @authuser = Authuser.find(authuser_id)
    approval_user = current_user
    @user_detail = UserDetail.new
    @user_detail.username = @authuser.username
    @user_detail.email = @authuser.email

    if @authuser.update_columns(approved: true, user_detail_id: approval_user.id)
      if @user_detail.save
        flash[:notice] = "User Approved"
        redirect_to authusers_path
      else 
        flash[:error] = @user_detail.errors.full_messages if @user_detail.errors.full_messages.any?
        flash[:alert] = "Error while inserting to user details.."
        redirect_to authusers_path
      end
    else 
      flash[:alert] = "Error while approving.."
      redirect_to authusers_path
    end
  end
  def reject_user
    authuser_id = params[:id]
    @authuser = Authuser.find(authuser_id)
    if @authuser.destroy
      flash.now[:notice] = "User Rejected.."
      redirect_to authusers_path
    else 
      flash.now[:alert] = "Error while rejecting.."
      redirect_to authusers_path
    end
  end

  # GET /authusers or /authusers.json
  def index
    @authusers = Authuser.all
  end

  # GET /authusers/1 or /authusers/1.json
 

  # GET /authusers/new
  # def new
  #   @authuser = Authuser.new
  # end

  # # GET /authusers/1/edit
  # def edit
  # end

  # # POST /authusers or /authusers.json
  # def create
  #   @authuser = Authuser.new(authuser_params)

  #   respond_to do |format|
  #     if @authuser.save
  #       format.html { redirect_to authuser_url(@authuser), notice: "Authuser was successfully created." }
  #       format.json { render :show, status: :created, location: @authuser }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @authuser.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /authusers/1 or /authusers/1.json
  # def update
  #   respond_to do |format|
  #     if @authuser.update(authuser_params)
  #       format.html { redirect_to authuser_url(@authuser), notice: "Authuser was successfully updated." }
  #       format.json { render :show, status: :ok, location: @authuser }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @authuser.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /authusers/1 or /authusers/1.json
  # def destroy
  #   @authuser.destroy

  #   respond_to do |format|
  #     format.html { redirect_to authusers_url, notice: "Authuser was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_authuser
      @authuser = Authuser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def authuser_params
      params.require(:authuser).permit(:username, :email, :password, :approved, :approved_by)
    end

    def authuser_signin_params
      
      params.require(:authuser).permit(:username, :password)
    end

    
end

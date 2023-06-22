class UserDetailsController < ApplicationController
  before_action :require_user
  before_action :require_admin, only: [:index, :new, :create]
 


  # GET /user_details or /user_details.json
  def index
    @user_details = UserDetail.all
  end 

  # GET /user_details/1 or /user_details/1.json
  def show
    @user_detail = UserDetail.find(params[:id])

    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't view others' profile as you are not an admin.."
      redirect_to user_detail_path(current_user)
    end
  end

  def get_requests
      @requests = Payment.where(requested_user: current_user.username)  
  end

  # GET /user_details/new
  # def new
  #   @user_detail = UserDetail.new
  # end

  # GET /user_details/1/edit
  def edit
    @user_detail = UserDetail.find(params[:id])

    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't edit others' profile as you are not an admin.."
      redirect_to user_detail_path(current_user)
    end
  end

  # POST /user_details or /user_details.json
  # def create
  #   @user_detail = UserDetail.new(user_detail_params)
    
  #   @user_detail.admin = true if params[:admin] == "true"
  #   @user_detail.email = @user_detail.email.downcase  
  #   respond_to do |format|
  #     if @user_detail.save
  #       format.html { redirect_to user_detail_url(@user_detail), notice: "User detail was successfully created." }
  #       format.json { render :show, status: :created, location: @user_detail }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @user_detail.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /user_details/1 or /user_details/1.json
  def update
    @user_detail = UserDetail.find(params[:id])

    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't edit others' profile as you are not an admin.."
      redirect_to user_detail_path(current_user)
    else
        
        if Authuser.find_by(username: params[:user_detail][:username]) && Authuser.find_by(username: params[:user_detail][:username]).id != params[:id].to_i
          
          flash[:alert] = "Username already exists.."
          if current_user.username != params[:user_detail][:username]
            redirect_to authusers_path
            return
          else
            redirect_to edit_user_detail_path(current_user)
            return 
          end
        end
        if params[:user_detail][:admin] == "1"
          @user_detail.admin = true 
        elsif params[:user_detail][:username] == current_user.username && params[:user_detail][:admin] == "0"
            flash[:alert] = "You can't depromote yourselves.."
            redirect_to edit_user_detail_path(current_user)
            return
        elsif params[:user_detail][:username] != current_user.username && params[:user_detail][:admin] == "0"
          @user_detail.admin = false 
        end
        if @user_detail.update(user_detail_params)
          flash[:notice] = "User Details Updated.."
          redirect_to user_detail_path(current_user)
        else
          flash[:alert] = @user_detail.errors.full_messages
          redirect_to edit_user_detail_path(current_user)
        end
        
      end
  end

  # DELETE /user_details/1 or /user_details/1.json
  def destroy
    @user_detail = UserDetail.find(params[:id])

    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't view others' profile as you are not an admin.."
      redirect_to user_detail_path(current_user)
    elsif @user_detail == current_user
      flash[:alert]="You can't delete your own account"
      redirect_to user_details_path
    else
      @authuser = Authuser.find_by(username:@user_detail.username)
      @user_detail.destroy
      @authuser.destroy
      respond_to do |format|
        format.html { redirect_to user_details_url, notice: "User detail is successfully destroyed." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_detail
      @user_detail = UserDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_detail_params
      params.require(:user_detail).permit(:username, :email, :role)
    end
end

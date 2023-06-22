class PaymentsController < ApplicationController
  # skip_before_action :verify_authenticity_token, only: [:approve_payment, :approve_payment_user]
  before_action :require_user
  before_action :require_admin, only: [:index]
  before_action :set_payment, only: %i[ show edit update destroy ]
  


  helper_method :approve_payment, :approve_payment_user

  # GET /payments or /payments.json
  def index
    @payments = Payment.all
  end

  # GET /payments/1 or /payments/1.json
  def show
    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't view others' payments as you are not an admin.."
      redirect_to user_detail_path(current_user)
    end
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't edit others' profile as you are not an admin.."
      redirect_to user_detail_path(current_user)
    end
  end

  # POST /payments or /payments.json
  def create
    
    @payment = Payment.new(params.require(:payment).permit(:approval_user, :payment_no))
    if Payment.find_by(payment_no: @payment.payment_no)
      flash[:alert] = "Payment No was already taken.."
      redirect_to new_payment_path
      return
    end
    user = UserDetail.find_by(username: @payment.approval_user)
    flash.now[:alert] = "No user present.." if !user
    @payment.user_detail = user
    if @payment.approval_user == current_user.username
      flash[:alert] = "You can't request for your own approval.."
      redirect_to new_payment_path
    else
      @payment.requested_user = current_user.username
      respond_to do |format|
        if @payment.save
          format.html { redirect_to payment_url(@payment), notice: "Payment was successfully created." }
          format.json { render :show, status: :created, location: @payment }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @payment.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    @payment = Payment.new(update_params)
    @payment.id = params[:id]
    @org = Payment.find(@payment.id)

    
    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't update others' payments as you are not an admin.."
      redirect_to user_detail_path(current_user)
    elsif Payment.find_by(payment_no: @payment.payment_no) && Payment.find_by(payment_no: @payment.payment_no) != @org 
      flash[:alert] = "Payment No was already taken.."
      redirect_to edit_payment_path
      return
    elsif @payment.approved
      flash[:alert] = "Payment already approved.. Can't edit anymore" 
    elsif update_params[:approval_user] == current_user.username
      flash[:alert] = "You can't specify your name as Payment approver"
    elsif @org.update(payment_no: @payment.payment_no, approval_user: @payment.approval_user)
      flash[:notice] = "Payment details updated.."
    else 
      flash[:alert] = @payment.errors.full_messages
    end
    redirect_to payments_path
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't delete others' payments as you are not an admin.."
      redirect_to user_detail_path(current_user)
    else @payment.destroy
      redirect_to payments_path
    end
  end

  def approve_payment
    if !current_user.admin && @user_detail != current_user
      flash[:alert] = "You can't approve others' payments as you are not an admin.."
      redirect_to user_detail_path(current_user)
    else
      payment_id = params[:id]
      @payment = Payment.find(payment_id)
      approveduser = UserDetail.find(current_user.id)
        
      if @payment.update(approved: true, approved_user: approveduser.username)
        flash[:notice] = "Payment Approved.."
        redirect_to payments_path
      else 
        flash[:alert] = "Payment not approved.."
        redirect_to payments_path
      end
    end
  end
  def approve_payment_user
    @user_detail = Payment.find(params[:id]).approval_user
    
    if !current_user.admin && @user_detail != current_user.username
      flash[:alert] = "You can't approve others' payments as you are not an admin.."
      redirect_to user_detail_path(current_user)
    else
      payment_id = params[:id]
      @payment = Payment.find(payment_id)
      approveduser = UserDetail.find(current_user.id)
      if @payment.update(approved: true, approved_user: approveduser.username)
        flash[:notice] = "Payment Approved.."
        redirect_to user_detail_path(@payment.user_detail_id)
      else 
        flash[:alert] = "Payment not approved.."
        redirect_to user_detail_path(@payment.user_detail_id)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:approval_user)
    end

    def update_params
      params.require(:payment).permit(:payment_no, :approval_user, :payment_no)
    end
end

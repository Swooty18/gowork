# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update destroy orders proposals]
  before_action :correct_user, only: %i[edit update orders orders proposals]
  before_action :admin_user, only: :destroy

  def index
    @users = if current_user.admin?
               User.paginate(page: params[:page])
             else
               User.where(activated: true).paginate(page: params[:page])
             end
    @users = @users.where(" ' ' || lower(first_name) || ' ' || lower(last_name) || ' ' LIKE ?", "%#{params[:search].downcase}%").paginate(page: params[:page]) if params[:search]
  end

  def show
    @user = User.find(params[:id])
    @responses = Response.where('user_id = ?', @user.id).paginate(page: params[:page])
    redirect_to root_url && return unless User.where(activated: true)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.avatar.attach(params[:avatar])
    if @user.save
      if @user.send_activation_email
      flash[:info] = 'Перевір пошту для активації аккаунту'
      redirect_to root_url
      else
        @user.destroy
        flash[:info] = 'Проблеми з надсиланням листа. Попробуй зареєструватись пізніше.'
        redirect_to root_url
      end
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Профіль оновлено'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'Користувача видалено'
    redirect_to users_url
  end

  def orders
    @user = User.find(params[:id])
    if params[:status] == 'Активне'
      @orders = @user.orders.where('status = ? and duedate >=?', params[:status], Time.now).paginate(page: params[:page], per_page: 20)
    elsif params[:status] == 'Виконується' || params[:status] == 'Завершене'
      @orders = @user.orders.where('status = ?', params[:status]).paginate(page: params[:page], per_page: 20)
    elsif params[:status] == 'Незавершене'
      @orders = @user.orders.where('duedate < ?', Time.now).paginate(page: params[:page], per_page: 20)
    else
      @orders = @user.orders.where('status = ? and duedate >=?', 'Активне', Time.now).paginate(page: params[:page], per_page: 20)
    end
    if params[:is_used] == "true" && (params[:title_or_description] || params[:category_id] || params[:city] || params[:min_price] || params[:max_price] || params[:status])
      @orders = @orders.search_by(params[:title_or_description],
                                       params[:category_id],
                                       params[:city],
                                       params[:min_price],
                                       params[:max_price]).paginate(page: params[:page], per_page: 20)
    end
  end

  def proposals
    @user = User.find(params[:id])
    @proposals = @user.proposals.paginate(page: params[:page], per_page: 20)
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :city,
      :description,
      :password,
      :password_confirmation,
      :avatar
    )
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end

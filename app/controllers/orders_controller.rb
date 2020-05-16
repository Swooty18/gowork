class OrdersController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]
  before_action :correct_user, only: %i[destroy edit update]
  before_action :status_check

  def status_check
    orders = Order.where('status = ? and duedate < ?', 'active', Time.now)
    orders.each do |order| 
      order.status = 'ended' 
      order.save
    end
  end

  def index
      @orders = Order.where('status = ? and duedate >= ?','active', Time.now).paginate(page: params[:page])
  end

  def show
    @order = Order.find(params[:id])
    @proposals = @order.proposals.paginate(page: params[:page])
  end

  def new
    @order = current_user.orders.build if logged_in?
  end

  def create
    @order = current_user.orders.build(order_params)
    @order.status = 'active'
    if @order.save
      flash[:success] = "Замовлення створено!"
      redirect_to orders_url(current_user)
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def edit
      if current_user.admin?
        @order = Order.find_by(id: params[:id])
      else
        @order = current_user.orders.find_by(id: params[:id])
        if @order.status != 'active'
          flash[:success] = 'Замовлення виконується/завершене'
          redirect_to order_url
        end
      end
  end

  def update
    if current_user.admin?
      @order = Order.find_by(id: params[:id])
    else
      @order = current_user.orders.find_by(id: params[:id])
    end
    @order.status = 'active'
    if @order.update(order_params)
      flash[:success] = 'Дані замовлення оновлено'
      redirect_to order_url
    else
      render 'edit'
    end
  end

  def destroy
    @order.destroy
    flash[:success] = 'Замовлення видалено'
    redirect_to orders_url(current_user)
  end

  private

  def admin_user
    redirect_to(root_url) unless current_user.try(:admin?)
  end

  def order_params
    params.require(:order).permit(
      :title,
      :description,
      :skills,
      :city,
      :duedate,
      :category_id,
      :price,
      :status
    )
  end

  # def category_params
  #   params.require(:category).permit(:category_id)
  # end

  # def correct_user
  #   @order = current_user.orders.find_by(id: params[:id])
  #   redirect_to orders_url(current_user) if @order.nil?
  # end

  def correct_user
    if current_user.admin?
      @order = Order.find_by(id: params[:id])
    else
      @order = current_user.orders.find_by(id: params[:id])
    end
    redirect_to orders_url(current_user) if @order.nil?
  end
end

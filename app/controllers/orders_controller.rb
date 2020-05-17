class OrdersController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]
  before_action :correct_user, only: %i[destroy edit update]
  before_action :status_check

  def status_check
    orders = Order.where('status = ? and duedate < ?', 'Активне', Time.now)
    orders.each do |order|
      order.status = 'Незавершене'
      order.save
    end
  end

  def index
      @orders = Order.where('status = ? and duedate >= ? and user_id != ?','Активне', Time.now, current_user.id).paginate(page: params[:page])
      @orders = Order.all.paginate(page: params[:page]) if current_user.admin?
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
    @order.status = 'Активне'
    if @order.save
      flash[:success] = "Замовлення створено!"
      redirect_to orders_url(current_user)
    else
      render 'new'
    end
  end

  def edit
      if current_user.admin?
        @order = Order.find_by(id: params[:id])
      else
        @order = current_user.orders.find_by(id: params[:id])
        if @order.status != 'Активне'
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
    @order.status = 'Активне'
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

  def finish_order
    @order = Order.find(params[:id])
    @order.update_attribute(:status, 'Заввершене')
    redirect_to @order
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

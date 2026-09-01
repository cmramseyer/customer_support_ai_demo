class OrdersController < ApplicationController
  before_action :set_product, only: :create

  def index
    @orders = current_user.orders.includes(:product).order(created_at: :desc)
  end

  def create
    @order = current_user.orders.build(order_params.merge(product: @product, unit_price: @product.price, status: :pending))

    if @order.save
      redirect_to @product, notice: "Order was created successfully."
    else
      @comments = @product.comments.includes(:user).order(:created_at)
      @comment = Comment.new
      render "products/show", status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def order_params
    params.expect(order: [ :quantity, :payment_method ])
  end
end

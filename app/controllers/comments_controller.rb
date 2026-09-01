class CommentsController < ApplicationController
  before_action :set_product

  def create
    @comment = @product.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @product, notice: "Comment was added successfully." }
        format.json do
          render json: { html: render_to_string(partial: "comments/comment", formats: [ :html ], locals: { comment: @comment }) }, status: :created
        end
      end
    else
      respond_to do |format|
        format.html do
          @comments = @product.comments.includes(:user).order(:created_at)
          render "products/show", status: :unprocessable_entity
        end
        format.json { render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def comment_params
    params.expect(comment: [ :body ])
  end
end

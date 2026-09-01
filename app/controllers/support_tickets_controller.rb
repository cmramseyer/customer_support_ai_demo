class SupportTicketsController < ApplicationController
  before_action :set_order

  def create
    @support_ticket = @order.support_tickets.build(support_ticket_params)

    if @support_ticket.save
      respond_to do |format|
        format.html { redirect_to orders_path, notice: "Support ticket was created successfully." }
        format.json { head :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to orders_path, alert: @support_ticket.errors.full_messages.to_sentence }
        format.json { render json: { errors: @support_ticket.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end

  def support_ticket_params
    params.expect(support_ticket: [ :comment ])
  end
end

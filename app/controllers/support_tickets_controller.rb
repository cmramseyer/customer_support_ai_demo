class SupportTicketsController < ApplicationController
  before_action :set_order, only: :create
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize SupportTicket
    @support_tickets = policy_scope(SupportTicket).includes(:order).order(created_at: :desc)
  end

  def create
    @support_ticket = @order.support_tickets.build(support_ticket_params)
    authorize @support_ticket

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

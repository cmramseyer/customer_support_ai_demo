class SupportTicketsController < ApplicationController
  before_action :set_order, only: %i[create resolution]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize SupportTicket
    @support_tickets = policy_scope(SupportTicket).includes(:order).order(created_at: :desc)
  end

  def show
    @support_ticket = SupportTicket.find(params[:id])
    authorize @support_ticket
  end

  def close
    @support_ticket = SupportTicket.find(params[:id])
    authorize @support_ticket, :close?

    if @support_ticket.update(resolution_response: resolution_response_params[:resolution_response], status: :closed, closed_by_user: current_user)
      redirect_to @support_ticket, notice: "Support ticket was closed successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def resolution
    @support_ticket = @order.support_tickets.closed.order(updated_at: :desc).find(params[:id])
    authorize @support_ticket, :resolution?
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

  def resolution_response_params
    params.expect(support_ticket: [ :resolution_response ])
  end
end

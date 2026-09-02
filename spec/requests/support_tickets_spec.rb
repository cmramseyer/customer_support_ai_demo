require "rails_helper"

RSpec.describe "SupportTickets", type: :request do
  include ActiveJob::TestHelper

  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:order) { Order.create!(product: product, user: user, quantity: 2, payment_method: :credit_card, unit_price: product.price) }

  before { sign_in(user) }

  it "creates an active support ticket for the current user's order" do
    expect do
      post order_support_tickets_path(order), params: { support_ticket: { comment: "The headset will not connect." } }, as: :json
    end.to change(SupportTicket, :count).by(1)

    support_ticket = SupportTicket.last
    expect(response).to have_http_status(:created)
    expect(support_ticket).to have_attributes(order: order, comment: "The headset will not connect.", status: "active")
    expect(enqueued_jobs).to include(hash_including(job: AnalyzeSupportTicketJob, args: [ support_ticket.id ]))
  end

  it "returns validation errors without creating a support ticket" do
    expect do
      post order_support_tickets_path(order), params: { support_ticket: { comment: "" } }, as: :json
    end.not_to change(SupportTicket, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.fetch("errors")).to include("Comment can't be blank")
  end

  it "does not create a support ticket for another user's order" do
    other_user = User.create!(email: "other@example.com", password: "password", password_confirmation: "password")
    other_order = Order.create!(product: product, user: other_user, quantity: 1, payment_method: :cash, unit_price: product.price)

    expect do
      post order_support_tickets_path(other_order), params: { support_ticket: { comment: "I should not access this order." } }, as: :json
    end.not_to change(SupportTicket, :count)

    expect(response).to have_http_status(:not_found)
  end

  it "allows an administrator to view every support ticket" do
    own_ticket = SupportTicket.create!(order: order, comment: "The headset will not connect.")
    other_user = User.create!(email: "other@example.com", password: "password", password_confirmation: "password")
    other_order = Order.create!(product: product, user: other_user, quantity: 1, payment_method: :cash, unit_price: product.price)
    other_ticket = SupportTicket.create!(order: other_order, comment: "The lamp is damaged.")
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)

    sign_in(admin)
    get support_tickets_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Ticket ##{own_ticket.id}", "Order ##{order.id}", own_ticket.comment, own_ticket.status.humanize)
    expect(response.body).to include("Ticket ##{other_ticket.id}", "Order ##{other_order.id}", other_ticket.comment, other_ticket.status.humanize)
    expect(response.body).to include("href=\"/support_tickets/#{own_ticket.id}\"", "href=\"/support_tickets/#{other_ticket.id}\"")
    expect(response.body).to include(">Support Tickets</a>")
    expect(response.body).not_to include(">Orders</a>")
  end

  it "prevents regular users from viewing support tickets" do
    get support_tickets_path

    expect(response).to redirect_to(products_path)
    expect(flash[:alert]).to eq("You are not authorized to perform this action.")
  end

  it "allows an administrator to view ticket analysis fields" do
    support_ticket = SupportTicket.create!(order: order, comment: "The headset will not connect.")
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)

    sign_in(admin)
    get support_ticket_path(support_ticket)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(support_ticket.comment, "Priority", "Problem", "Category", "Related tickets", "Recommended action", "Recommended response", "Sentiment", "Not available", "None")
  end

  it "prevents regular users from viewing a support ticket" do
    support_ticket = SupportTicket.create!(order: order, comment: "The headset will not connect.")

    get support_ticket_path(support_ticket)

    expect(response).to redirect_to(products_path)
    expect(flash[:alert]).to eq("You are not authorized to perform this action.")
  end

  it "allows an administrator to close a ticket with a response" do
    support_ticket = SupportTicket.create!(order: order, comment: "The headset will not connect.")
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)

    sign_in(admin)
    patch close_support_ticket_path(support_ticket), params: { support_ticket: { resolution_response: "A replacement headset has been shipped." } }

    expect(response).to redirect_to(support_ticket)
    expect(support_ticket.reload).to have_attributes(status: "closed", resolution_response: "A replacement headset has been shipped.", closed_by_user: admin)
  end

  it "does not close a ticket without a response" do
    support_ticket = SupportTicket.create!(order: order, comment: "The headset will not connect.")
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)

    sign_in(admin)
    patch close_support_ticket_path(support_ticket), params: { support_ticket: { resolution_response: "" } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(support_ticket.reload).to be_active
  end

  it "allows an order owner to view a closed ticket resolution" do
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)
    support_ticket = SupportTicket.create!(order: order, comment: "The headset will not connect.", status: :closed, resolution_response: "A replacement headset has been shipped.", closed_by_user: admin)

    get resolution_order_support_ticket_path(order, support_ticket)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(support_ticket.comment, support_ticket.resolution_response)
  end
end

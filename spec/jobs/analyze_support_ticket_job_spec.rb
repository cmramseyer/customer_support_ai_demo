require "rails_helper"

RSpec.describe AnalyzeSupportTicketJob, type: :job do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:order) { Order.create!(product:, user:, quantity: 1, payment_method: :credit_card, unit_price: product.price) }
  let(:ticket) { SupportTicket.create!(order:, comment: "Can I return my headset?") }

  it "persists the analysis without changing the ticket status" do
    analysis = {
      "priority" => "low",
      "category" => "returns",
      "problem" => "return request",
      "recommended_action" => "Explain the return policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "neutral"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))

    described_class.perform_now(ticket.id)

    expect(ticket.reload).to have_attributes(analysis.merge("status" => "active"))
  end
end

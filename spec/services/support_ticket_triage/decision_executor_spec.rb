require "rails_helper"

RSpec.describe SupportTicketTriage::DecisionExecutor do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:order) { Order.create!(product:, user:, quantity: 1, payment_method: :credit_card, unit_price: product.price) }
  let(:ticket) { SupportTicket.create!(order:, comment: "Can I return my headset?") }
  let(:analysis) do
    {
      "priority" => "low",
      "category" => "information_request",
      "problem" => "return policy question",
      "recommended_action" => "Share the policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "neutral"
    }
  end

  it "persists analysis and decision attributes together" do
    decision = SupportTicketTriage::Decision.new(
      outcome: :auto_close,
      severity: 10,
      attributes: { status: :closed, resolution_response: analysis.fetch("recommended_response"), closed_by_user: nil }
    )

    described_class.new.call(ticket:, analysis:, decision:)

    expect(ticket.reload).to have_attributes(analysis.merge("status" => "closed", "resolution_response" => analysis.fetch("recommended_response"), "closed_by_user" => nil))
  end
end

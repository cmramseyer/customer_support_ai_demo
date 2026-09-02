require "rails_helper"

RSpec.describe SupportTicketTriage::Processor do
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

  it "persists analysis and applies an auto-close decision" do
    decision = SupportTicketTriage::Decision.new(
      outcome: :auto_close,
      severity: 10,
      attributes: { status: :closed, resolution_response: analysis.fetch("recommended_response"), closed_by_user: nil }
    )
    checker = instance_double(SupportTicketTriage::RuleChecker, call: decision)

    returned_decision = described_class.new(ticket:, analysis:, rule_checker: checker).call

    expect(returned_decision).to eq(decision)
    expect(ticket.reload).to have_attributes(analysis.merge("status" => "closed", "resolution_response" => analysis.fetch("recommended_response"), "closed_by_user" => nil))
  end

  it "preserves a manual closure when no auto-close rule applies" do
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)
    ticket.update!(status: :closed, resolution_response: "Manual response", closed_by_user: admin)

    described_class.new(ticket:, analysis:).call

    expect(ticket.reload).to have_attributes(status: "closed", resolution_response: "Manual response", closed_by_user: admin)
  end
end

require "rails_helper"

RSpec.describe AnalyzeSupportTicketJob, type: :job do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:order) { Order.create!(product:, user:, quantity: 1, payment_method: :credit_card, unit_price: product.price) }
  let(:ticket) { SupportTicket.create!(order:, comment: "Can I return my headset?") }

  it "delegates the analysis to the triage processor" do
    analysis = {
      "priority" => "low",
      "category" => "information_request",
      "problem" => "return policy question",
      "recommended_action" => "Share the policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "neutral"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))
    processor = instance_double(SupportTicketTriage::Processor, call: SupportTicketTriage::Decision.no_change)
    allow(SupportTicketTriage::Processor).to receive(:new).and_return(processor)

    described_class.perform_now(ticket.id)

    expect(SupportTicketTriage::Processor).to have_received(:new).with(ticket:, analysis:)
    expect(processor).to have_received(:call)
  end
end

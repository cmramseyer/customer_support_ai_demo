require "rails_helper"

RSpec.describe AnalyzeSupportTicketJob, type: :job do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:order) { Order.create!(product:, user:, quantity: 1, payment_method: :credit_card, unit_price: product.price) }
  let(:ticket) { SupportTicket.create!(order:, comment: "Can I return my headset?") }

  it "automatically closes a low-risk documentation ticket" do
    analysis = {
      "priority" => "low",
      "category" => "information_request",
      "problem" => "return policy question",
      "recommended_action" => "Share the policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "neutral"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))

    described_class.perform_now(ticket.id)

    expect(ticket.reload).to have_attributes(analysis.merge("status" => "closed", "resolution_response" => analysis.fetch("recommended_response"), "closed_by_user" => nil))
  end

  it "keeps a ticket active when the category does not qualify for automatic closure" do
    analysis = {
      "priority" => "low",
      "category" => "return_request",
      "problem" => "return request",
      "recommended_action" => "Explain the return policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "neutral"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))

    described_class.perform_now(ticket.id)

    expect(ticket.reload).to have_attributes(analysis.merge("status" => "active"))
  end

  it "keeps a ticket active when the sentiment does not qualify for automatic closure" do
    analysis = {
      "priority" => "low",
      "category" => "information_request",
      "problem" => "return policy question",
      "recommended_action" => "Share the policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "bad"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))

    described_class.perform_now(ticket.id)

    expect(ticket.reload).to be_active
  end

  it "keeps a ticket active when the priority does not qualify for automatic closure" do
    analysis = {
      "priority" => "medium",
      "category" => "information_request",
      "problem" => "return policy question",
      "recommended_action" => "Share the policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "good"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))

    described_class.perform_now(ticket.id)

    expect(ticket.reload).to be_active
  end

  it "does not overwrite a manual closure when analysis finishes late" do
    admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true)
    ticket.update!(status: :closed, resolution_response: "Manual response", closed_by_user: admin)
    analysis = {
      "priority" => "low",
      "category" => "information_request",
      "problem" => "return policy question",
      "recommended_action" => "Share the policy.",
      "recommended_response" => "You can return the headset within 30 days.",
      "sentiment" => "good"
    }
    allow(SupportTicketAnalyzer).to receive(:new).and_return(instance_double(SupportTicketAnalyzer, analyze: analysis))

    described_class.perform_now(ticket.id)

    expect(ticket.reload).to have_attributes(status: "closed", resolution_response: "Manual response", closed_by_user: admin)
  end
end

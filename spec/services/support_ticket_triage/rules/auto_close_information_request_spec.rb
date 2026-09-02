require "rails_helper"

RSpec.describe SupportTicketTriage::Rules::AutoCloseInformationRequest do
  let(:ticket) { SupportTicket.new(status: :active) }
  let(:analysis) do
    {
      "priority" => "low",
      "sentiment" => "neutral",
      "category" => "information_request",
      "recommended_response" => "The product manual is available in your account."
    }
  end

  it "returns an auto-close decision for a low-risk information request" do
    decision = described_class.new.call(ticket:, analysis:)

    expect(decision).to have_attributes(
      outcome: :auto_close,
      severity: 10,
      attributes: { status: :closed, resolution_response: analysis.fetch("recommended_response"), closed_by_user: nil }
    )
  end

  it "returns no decision when a required condition is not met" do
    analysis["sentiment"] = "bad"

    expect(described_class.new.call(ticket:, analysis:)).to be_nil
  end

  it "returns no decision for a non-low priority" do
    analysis["priority"] = "medium"

    expect(described_class.new.call(ticket:, analysis:)).to be_nil
  end

  it "returns no decision for a category other than an information request" do
    analysis["category"] = "return_request"

    expect(described_class.new.call(ticket:, analysis:)).to be_nil
  end

  it "returns no decision without a recommended response" do
    analysis["recommended_response"] = ""

    expect(described_class.new.call(ticket:, analysis:)).to be_nil
  end

  it "returns no decision for an already closed ticket" do
    ticket.status = :closed

    expect(described_class.new.call(ticket:, analysis:)).to be_nil
  end
end

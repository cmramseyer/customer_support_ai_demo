require "rails_helper"

RSpec.describe SupportTicketAutoClosureRules do
  let(:ticket) { SupportTicket.new(status: :active) }
  let(:analysis) do
    {
      "priority" => "low",
      "sentiment" => "neutral",
      "category" => "information_request",
      "recommended_response" => "The product manual is available in your account."
    }
  end

  subject(:rules) { described_class.new(ticket:, analysis:) }

  it "accepts a neutral low-risk information request" do
    expect(rules).to be_eligible
  end

  it "accepts a good low-risk information request" do
    analysis["sentiment"] = "good"

    expect(rules).to be_eligible
  end

  it "rejects a non-low priority" do
    analysis["priority"] = "medium"

    expect(rules).not_to be_eligible
  end

  it "rejects a category other than an information request" do
    analysis["category"] = "return_request"

    expect(rules).not_to be_eligible
  end

  it "rejects bad sentiment" do
    analysis["sentiment"] = "bad"

    expect(rules).not_to be_eligible
  end

  it "rejects a missing response" do
    analysis["recommended_response"] = ""

    expect(rules).not_to be_eligible
  end

  it "rejects an already closed ticket" do
    ticket.status = :closed

    expect(rules).not_to be_eligible
  end
end

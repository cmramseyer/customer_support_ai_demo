require "rails_helper"

RSpec.describe SupportTicketTriage::RuleChecker do
  Rule = Data.define(:decision) do
    def call(ticket:, analysis:)
      decision
    end
  end

  let(:ticket) { SupportTicket.new(status: :active) }
  let(:analysis) { {} }

  it "returns no_change when no rules apply" do
    decision = described_class.new(rules: [ Rule.new(nil) ]).call(ticket:, analysis:)

    expect(decision).to eq(SupportTicketTriage::Decision.no_change)
  end

  it "selects the highest severity decision independently of rule order" do
    auto_close = SupportTicketTriage::Decision.new(outcome: :auto_close, severity: 10, attributes: {})
    supervisor_review = SupportTicketTriage::Decision.new(outcome: :supervisor_review, severity: 100, attributes: {})

    decision = described_class.new(rules: [ Rule.new(auto_close), Rule.new(supervisor_review) ]).call(ticket:, analysis:)

    expect(decision).to eq(supervisor_review)
  end

  it "keeps an equal-severity decision when its outcome is the same" do
    first = SupportTicketTriage::Decision.new(outcome: :human_review, severity: 50, attributes: {})
    second = SupportTicketTriage::Decision.new(outcome: :human_review, severity: 50, attributes: {})

    decision = described_class.new(rules: [ Rule.new(second), Rule.new(first) ]).call(ticket:, analysis:)

    expect(decision).to eq(second)
  end

  it "returns no_change for incompatible decisions with equal severity" do
    first = SupportTicketTriage::Decision.new(outcome: :auto_close, severity: 10, attributes: {})
    second = SupportTicketTriage::Decision.new(outcome: :human_review, severity: 10, attributes: {})

    decision = described_class.new(rules: [ Rule.new(first), Rule.new(second) ]).call(ticket:, analysis:)

    expect(decision).to eq(SupportTicketTriage::Decision.no_change)
  end
end

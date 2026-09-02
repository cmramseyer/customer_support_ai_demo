require "rails_helper"

RSpec.describe KnowledgeBaseChunker do
  it "returns a token-counted chunk for short content" do
    chunks = described_class.new("Refunds are available within 30 days.").call

    expect(chunks).to contain_exactly(have_attributes(content: "Refunds are available within 30 days.", token_count: be_positive))
  end

  it "splits long content into ordered overlapping chunks" do
    chunks = described_class.new(("refund policy " * 1_000).strip).call

    expect(chunks.size).to be > 1
    expect(chunks).to all(have_attributes(token_count: be <= described_class::MAX_TOKENS))
    expect(chunks.first.content).to include("refund policy")
    expect(chunks.last.content).to include("refund policy")
  end
end

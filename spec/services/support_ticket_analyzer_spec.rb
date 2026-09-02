require "rails_helper"

RSpec.describe SupportTicketAnalyzer do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:order) { Order.create!(product:, user:, quantity: 1, payment_method: :credit_card, unit_price: product.price) }
  let(:ticket) { SupportTicket.create!(order:, comment: "Can I return my headset?") }
  let(:client) { instance_double(OpenAI::Client) }
  let(:responses) { instance_double("Responses") }
  let(:document) { instance_double(KnowledgeBaseDocument, title: "Refund policy") }
  let(:chunk) { instance_double(KnowledgeBaseChunk, id: 7, content: "Refunds are available within 30 days.", knowledge_base_document: document) }
  let(:retriever) { instance_double(KnowledgeBaseRetriever, call: [ chunk ]) }

  before do
    allow(client).to receive(:responses).and_return(responses)
  end

  it "sends the ticket and retrieved sources to gpt-5-nano" do
    analysis = {
      priority: "low",
      category: "returns",
      problem: "return request",
      recommended_action: "Explain the return policy.",
      recommended_response: "You can return the headset within 30 days.",
      sentiment: "neutral"
    }
    allow(responses).to receive(:create).and_return(instance_double("Response", output_text: analysis.to_json))

    result = described_class.new(client:, retriever:).analyze(ticket)

    expect(responses).to have_received(:create).with(hash_including(
      model: "gpt-5-nano",
      input: array_including(hash_including(content: include(ticket.comment)), hash_including(content: include(chunk.content)))
    ))
    expect(result).to eq(analysis.stringify_keys)
  end

  it "rejects a non-JSON response" do
    allow(responses).to receive(:create).and_return(instance_double("Response", output_text: "not json"))

    expect { described_class.new(client:, retriever:).analyze(ticket) }
      .to raise_error(SupportTicketAnalyzer::Error, "OpenAI returned an invalid ticket analysis: JSON::ParserError")
  end
end

require "rails_helper"

RSpec.describe KnowledgeBaseRetriever do
  def vector(first, second)
    [ first, second ] + Array.new(1534, 0.0)
  end

  it "returns the nearest embedded chunks up to the requested limit" do
    document = KnowledgeBaseDocument.create!(title: "Refund policy", content: "Refunds are available within 30 days.")
    nearest = document.knowledge_base_chunks.create!(content: "Refunds are available within 30 days.", position: 0, token_count: 8, embedding: vector(1.0, 0.0))
    document.knowledge_base_chunks.create!(content: "Shipping takes five days.", position: 1, token_count: 5, embedding: vector(0.0, 1.0))
    embedding_client = instance_double(OpenaiEmbeddingClient, embed: [ vector(1.0, 0.0) ])

    chunks = described_class.new(embedding_client:).call("Can I get a refund?", limit: 1)

    expect(chunks).to eq([ nearest ])
    expect(chunks.first.knowledge_base_document).to eq(document)
  end
end

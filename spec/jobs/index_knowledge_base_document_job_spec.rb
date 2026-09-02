require "rails_helper"

RSpec.describe IndexKnowledgeBaseDocumentJob, type: :job do
  let(:document) { KnowledgeBaseDocument.create!(title: "Refund policy", content: "Refunds are available within 30 days.") }

  it "replaces a document's chunks with embedded chunks" do
    document.knowledge_base_chunks.create!(content: "Outdated", position: 0, token_count: 2, embedding: Array.new(1536, 0.1))
    embedding = Array.new(1536, 0.2)
    allow(OpenaiEmbeddingClient).to receive(:new).and_return(instance_double(OpenaiEmbeddingClient, embed: [ embedding ]))

    described_class.perform_now(document.id)

    expect(document.knowledge_base_chunks.reload).to contain_exactly(
      have_attributes(content: "Refunds are available within 30 days.", position: 0, token_count: be_positive, embedding: embedding)
    )
  end

  it "preserves existing chunks when the embedding response is invalid" do
    existing_chunk = document.knowledge_base_chunks.create!(content: "Existing", position: 0, token_count: 1, embedding: Array.new(1536, 0.1))
    allow(OpenaiEmbeddingClient).to receive(:new).and_return(instance_double(OpenaiEmbeddingClient, embed: []))

    described_class.perform_now(document.id)

    expect(document.knowledge_base_chunks.reload).to contain_exactly(existing_chunk)
  end
end

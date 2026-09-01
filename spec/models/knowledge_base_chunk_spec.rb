require 'rails_helper'

RSpec.describe KnowledgeBaseChunk, type: :model do
  let(:document) { KnowledgeBaseDocument.create!(title: "Support policy", content: "Support policy") }

  it "belongs to a document" do
    chunk = described_class.create!(knowledge_base_document: document, content: "Support policy", position: 0, token_count: 2)

    expect(chunk.knowledge_base_document).to eq(document)
  end

  it "requires a unique position within its document" do
    described_class.create!(knowledge_base_document: document, content: "First chunk", position: 0, token_count: 2)
    duplicate = described_class.new(knowledge_base_document: document, content: "Second chunk", position: 0, token_count: 2)

    expect(duplicate).not_to be_valid
  end
end

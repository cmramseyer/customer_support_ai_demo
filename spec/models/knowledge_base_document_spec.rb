require 'rails_helper'

RSpec.describe KnowledgeBaseDocument, type: :model do
  it "requires content" do
    expect(described_class.new).not_to be_valid
  end

  it "requires a title" do
    expect(described_class.new(content: "Support policy")).not_to be_valid
  end

  it "destroys its chunks" do
    document = described_class.create!(title: "Support policy", content: "Support policy")
    document.knowledge_base_chunks.create!(content: "Support policy", position: 0, token_count: 2)

    expect { document.destroy }.to change(KnowledgeBaseChunk, :count).by(-1)
  end
end

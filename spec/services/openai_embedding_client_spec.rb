require "rails_helper"

RSpec.describe OpenaiEmbeddingClient do
  let(:client) { instance_double(OpenAI::Client) }
  let(:embeddings) { instance_double("Embeddings") }

  before do
    allow(client).to receive(:embeddings).and_return(embeddings)
  end

  it "sends texts to the configured embedding model" do
    response = instance_double("Response", data: [ instance_double("Embedding", embedding: Array.new(1536, 0.1)) ])
    allow(embeddings).to receive(:create).and_return(response)

    result = described_class.new(client:).embed([ "Refunds are available within 30 days." ])

    expect(embeddings).to have_received(:create).with(
      input: [ "Refunds are available within 30 days." ],
      model: "text-embedding-3-small",
      dimensions: 1536
    )
    expect(result).to eq(response.data.map(&:embedding))
  end

  it "rejects missing or malformed embeddings" do
    response = instance_double("Response", data: [ instance_double("Embedding", embedding: [ 0.1 ]) ])
    allow(embeddings).to receive(:create).and_return(response)

    expect { described_class.new(client:).embed([ "Refund policy" ]) }
      .to raise_error(OpenaiEmbeddingClient::Error, "OpenAI returned invalid embeddings")
  end

  it "rejects an empty input list" do
    expect { described_class.new(client:).embed([]) }
      .to raise_error(ArgumentError, "texts must not be empty")
  end
end

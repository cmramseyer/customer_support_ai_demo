class OpenaiEmbeddingClient
  class Error < StandardError; end

  MODEL = "text-embedding-3-small"
  DIMENSIONS = 1536

  def initialize(client: OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY")))
    @client = client
  end

  def embed(texts)
    raise ArgumentError, "texts must not be empty" if texts.empty?

    response = @client.embeddings.create(input: texts, model: MODEL, dimensions: DIMENSIONS)
    embeddings = response.data.map(&:embedding)

    unless embeddings.size == texts.size && embeddings.all? { |embedding| embedding.size == DIMENSIONS }
      raise Error, "OpenAI returned invalid embeddings"
    end

    embeddings
  rescue OpenAI::Errors::Error => error
    raise Error, "OpenAI embedding request failed: #{error.class}"
  end
end

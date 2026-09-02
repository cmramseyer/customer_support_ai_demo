class KnowledgeBaseRetriever
  def initialize(embedding_client: OpenaiEmbeddingClient.new)
    @embedding_client = embedding_client
  end

  def call(query, limit: 5)
    embedding = @embedding_client.embed([ query ]).first

    KnowledgeBaseChunk
      .includes(:knowledge_base_document)
      .where.not(embedding: nil)
      .nearest_neighbors(:embedding, embedding, distance: "cosine")
      .first(limit)
  end
end

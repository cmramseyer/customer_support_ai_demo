class IndexKnowledgeBaseDocumentJob < ApplicationJob
  retry_on OpenaiEmbeddingClient::Error, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(document_id)
    document = KnowledgeBaseDocument.find(document_id)
    chunks = KnowledgeBaseChunker.new(document.content).call
    embeddings = OpenaiEmbeddingClient.new.embed(chunks.map(&:content))
    raise OpenaiEmbeddingClient::Error, "OpenAI returned an incomplete embedding set" unless embeddings.size == chunks.size

    document.transaction do
      document.knowledge_base_chunks.delete_all
      chunks.zip(embeddings).each_with_index do |(chunk, embedding), position|
        document.knowledge_base_chunks.create!(
          content: chunk.content,
          position:,
          token_count: chunk.token_count,
          embedding:
        )
      end
    end
  end
end

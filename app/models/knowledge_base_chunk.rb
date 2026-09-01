class KnowledgeBaseChunk < ApplicationRecord
  belongs_to :knowledge_base_document
  has_neighbors :embedding

  validates :content, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: { scope: :knowledge_base_document_id }
  validates :token_count, numericality: { only_integer: true, greater_than: 0 }
end

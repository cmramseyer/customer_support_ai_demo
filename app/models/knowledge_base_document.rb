class KnowledgeBaseDocument < ApplicationRecord
  has_many :knowledge_base_chunks, -> { order(:position) }, dependent: :destroy

  validates :content, presence: true
end

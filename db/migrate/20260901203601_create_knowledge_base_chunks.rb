class CreateKnowledgeBaseChunks < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_base_chunks do |t|
      t.references :knowledge_base_document, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :position, null: false
      t.integer :token_count, null: false
      t.vector :embedding, limit: 1536

      t.timestamps
    end

    add_index :knowledge_base_chunks, %i[knowledge_base_document_id position], unique: true
    add_check_constraint :knowledge_base_chunks, "position >= 0", name: "knowledge_base_chunks_position_nonnegative"
    add_check_constraint :knowledge_base_chunks, "token_count > 0", name: "knowledge_base_chunks_token_count_positive"

    add_index :knowledge_base_chunks, :embedding, using: :hnsw, opclass: :vector_cosine_ops
  end
end

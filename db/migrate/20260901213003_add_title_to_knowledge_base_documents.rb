class AddTitleToKnowledgeBaseDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :knowledge_base_documents, :title, :string, null: false
  end
end

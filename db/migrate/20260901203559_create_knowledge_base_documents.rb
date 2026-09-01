class CreateKnowledgeBaseDocuments < ActiveRecord::Migration[8.1]
  def change
    enable_extension "vector"

    create_table :knowledge_base_documents do |t|
      t.text :content, null: false

      t.timestamps
    end
  end
end

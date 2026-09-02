namespace :knowledge do
  desc "Enqueue indexing for every knowledge base document"
  task reindex_all: :environment do
    KnowledgeBaseDocument.find_each do |document|
      IndexKnowledgeBaseDocumentJob.perform_later(document.id)
    end
  end

  desc "Index every knowledge base document immediately"
  task reindex_all_now: :environment do
    KnowledgeBaseDocument.find_each do |document|
      IndexKnowledgeBaseDocumentJob.perform_now(document.id)
      puts "Indexed document ##{document.id}: #{document.title}"
    end
  end
end

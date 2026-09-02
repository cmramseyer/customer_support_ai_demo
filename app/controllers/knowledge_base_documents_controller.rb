class KnowledgeBaseDocumentsController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize KnowledgeBaseDocument
    @knowledge_base_documents = policy_scope(KnowledgeBaseDocument).order(created_at: :desc)
  end

  def new
    @knowledge_base_document = KnowledgeBaseDocument.new
    authorize @knowledge_base_document
  end

  def create
    @knowledge_base_document = KnowledgeBaseDocument.new(knowledge_base_document_params)
    authorize @knowledge_base_document

    if @knowledge_base_document.save
      IndexKnowledgeBaseDocumentJob.perform_later(@knowledge_base_document.id)
      redirect_to knowledge_base_documents_path, notice: "Knowledge base document was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def knowledge_base_document_params
    params.expect(knowledge_base_document: [ :title, :content ])
  end
end

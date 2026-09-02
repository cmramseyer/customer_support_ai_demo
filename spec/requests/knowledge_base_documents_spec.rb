require "rails_helper"

RSpec.describe "KnowledgeBaseDocuments", type: :request do
  include ActiveJob::TestHelper

  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:admin) { User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true) }

  before { sign_in(user) }

  it "allows an administrator to list knowledge base documents" do
    document = KnowledgeBaseDocument.create!(title: "Refund policy", content: "Refunds are available within 30 days.")

    sign_in(admin)
    get knowledge_base_documents_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(document.title, document.content, ">Knowledge Base</a>", "href=\"/knowledge_base_documents/new\"")
  end

  it "allows an administrator to create a knowledge base document" do
    sign_in(admin)

    expect do
      post knowledge_base_documents_path, params: { knowledge_base_document: { title: "Refund policy", content: "Refunds are available within 30 days." } }
    end.to change(KnowledgeBaseDocument, :count).by(1)
      .and have_enqueued_job(IndexKnowledgeBaseDocumentJob)

    document = KnowledgeBaseDocument.last
    expect(response).to redirect_to(knowledge_base_documents_path)
    expect(document).to have_attributes(title: "Refund policy", content: "Refunds are available within 30 days.")
    expect(document.knowledge_base_chunks).to be_empty
  end

  it "prevents regular users from viewing knowledge base documents" do
    get knowledge_base_documents_path

    expect(response).to redirect_to(products_path)
    expect(flash[:alert]).to eq("You are not authorized to perform this action.")
  end
end

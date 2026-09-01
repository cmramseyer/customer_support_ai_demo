require "rails_helper"

RSpec.describe KnowledgeBaseDocumentPolicy do
  let(:admin) { User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", is_admin: true) }
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }

  it "allows only administrators to manage knowledge base documents" do
    %i[index? new? create?].each do |query|
      expect(described_class.new(admin, KnowledgeBaseDocument).public_send(query)).to be(true)
      expect(described_class.new(user, KnowledgeBaseDocument).public_send(query)).to be(false)
    end
  end
end

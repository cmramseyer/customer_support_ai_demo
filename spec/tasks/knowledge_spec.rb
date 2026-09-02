require "rails_helper"
require "rake"

RSpec.describe "knowledge:reindex_all" do
  include ActiveJob::TestHelper

  before do
    Rails.application.load_tasks unless Rake::Task.task_defined?("knowledge:reindex_all")
    clear_enqueued_jobs
  end

  after do
    Rake::Task["knowledge:reindex_all"].reenable
    Rake::Task["knowledge:reindex_all_now"].reenable
  end

  it "enqueues indexing for every document" do
    documents = [
      KnowledgeBaseDocument.create!(title: "Refund policy", content: "Refunds are available within 30 days."),
      KnowledgeBaseDocument.create!(title: "Shipping policy", content: "Shipping takes 5 days.")
    ]

    expect { Rake::Task["knowledge:reindex_all"].invoke }
      .to have_enqueued_job(IndexKnowledgeBaseDocumentJob).exactly(2).times

    expect(enqueued_jobs.map { |job| job.fetch(:args).first }).to match_array(documents.map(&:id))
  end

  it "indexes every document synchronously" do
    documents = [
      KnowledgeBaseDocument.create!(title: "Refund policy", content: "Refunds are available within 30 days."),
      KnowledgeBaseDocument.create!(title: "Shipping policy", content: "Shipping takes 5 days.")
    ]
    allow(IndexKnowledgeBaseDocumentJob).to receive(:perform_now)

    expect { Rake::Task["knowledge:reindex_all_now"].invoke }
      .to output("Indexed document ##{documents.first.id}: Refund policy\nIndexed document ##{documents.last.id}: Shipping policy\n").to_stdout

    expect(IndexKnowledgeBaseDocumentJob).to have_received(:perform_now).with(documents.first.id).ordered
    expect(IndexKnowledgeBaseDocumentJob).to have_received(:perform_now).with(documents.last.id).ordered
  end
end

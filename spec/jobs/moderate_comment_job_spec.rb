require "rails_helper"

RSpec.describe ModerateCommentJob, type: :job do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) { Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories") }
  let(:comment) { Comment.create!(product:, user:, body: "Works well for support calls.") }
  let(:moderation_client) { instance_double(OpenaiModerationClient) }

  before do
    allow(OpenaiModerationClient).to receive(:new).and_return(moderation_client)
    allow(moderation_client).to receive(:flagged?)
  end

  it "approves a comment when OpenAI does not flag it" do
    allow(moderation_client).to receive(:flagged?).with(comment.body).and_return(false)

    described_class.perform_now(comment.id)

    expect(comment.reload).to be_approved
    expect(user.reload.moderated_comments_count).to eq(0)
  end

  it "marks a comment as moderated and increments its author's counter when OpenAI flags it" do
    allow(moderation_client).to receive(:flagged?).with(comment.body).and_return(true)

    described_class.perform_now(comment.id)

    expect(comment.reload).to be_moderated
    expect(user.reload.moderated_comments_count).to eq(1)
  end

  it "does not process an already moderated comment twice" do
    comment.update!(status: :moderated)
    user.update!(moderated_comments_count: 1)

    described_class.perform_now(comment.id)

    expect(moderation_client).not_to have_received(:flagged?)
    expect(user.reload.moderated_comments_count).to eq(1)
  end
end

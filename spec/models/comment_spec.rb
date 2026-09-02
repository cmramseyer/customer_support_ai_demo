require "rails_helper"

RSpec.describe Comment do
  subject(:comment) do
    described_class.new(
      product: Product.create!(name: "Wireless headset", description: "Noise-cancelling headset.", price: 89.99, category: "Accessories"),
      user: User.create!(email: "user@example.com", password: "password", password_confirmation: "password"),
      body: "Works well for support calls."
    )
  end

  it "is valid with a product, user, and body" do
    expect(comment).to be_valid
  end

  it "defaults to pending review and enqueues moderation after creation" do
    expect { comment.save! }
      .to have_enqueued_job(ModerateCommentJob).with(comment.id)

    expect(comment).to be_pending_review
  end

  it "requires a body" do
    comment.body = ""

    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to include("can't be blank")
  end
end

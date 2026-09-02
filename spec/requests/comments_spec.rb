require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
  let(:product) do
    Product.create!(
      name: "Wireless headset",
      description: "Noise-cancelling headset for customer calls.",
      price: 89.99,
      category: "Accessories"
    )
  end

  before { sign_in(user) }

  it "shows only approved product comments with the author email and formatted timestamp" do
    approved_comment = Comment.create!(product: product, user: user, body: "Works well for support calls.", status: :approved)
    pending_comment = Comment.create!(product: product, user: user, body: "Still under review.")
    moderated_comment = Comment.create!(product: product, user: user, body: "Content removed by moderation.", status: :moderated)

    get product_path(product)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(user.email, approved_comment.body, approved_comment.created_at.strftime("%m/%d/%y %H:%M"))
    expect(response.body).not_to include(pending_comment.body, moderated_comment.body)
  end

  it "creates a pending comment for the authenticated user and queues moderation" do
    expect do
      post product_comments_path(product), params: { comment: { body: "Works well for support calls." } }, as: :json
    end.to change(Comment, :count).by(1)
      .and have_enqueued_job(ModerateCommentJob)

    comment = Comment.last
    expect(response).to have_http_status(:accepted)
    expect(comment).to have_attributes(product: product, user: user, body: "Works well for support calls.", status: "pending_review")
  end

  it "returns validation errors without creating a comment" do
    expect do
      post product_comments_path(product), params: { comment: { body: "" } }, as: :json
    end.not_to change(Comment, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.fetch("errors")).to include("Body can't be blank")
  end
end

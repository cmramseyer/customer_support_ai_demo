class Comment < ApplicationRecord
  belongs_to :product
  belongs_to :user

  enum :status, { pending_review: 0, approved: 1, moderated: 2 }, validate: true

  validates :body, presence: true

  after_create_commit :enqueue_moderation

  private

  def enqueue_moderation
    ModerateCommentJob.perform_later(id)
  end
end

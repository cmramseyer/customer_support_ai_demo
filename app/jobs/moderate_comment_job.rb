class ModerateCommentJob < ApplicationJob
  retry_on OpenaiModerationClient::Error, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(comment_id)
    comment = Comment.find(comment_id)
    return unless comment.pending_review?

    flagged = OpenaiModerationClient.new.flagged?(comment.body)

    comment.with_lock do
      return unless comment.pending_review?

      if flagged
        comment.user.increment!(:moderated_comments_count)
        comment.moderated!
      else
        comment.approved!
      end
    end
  end
end

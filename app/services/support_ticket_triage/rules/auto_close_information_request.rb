module SupportTicketTriage
  module Rules
    class AutoCloseInformationRequest
      AUTO_CLOSABLE_SENTIMENTS = %w[neutral good].freeze

      def call(ticket:, analysis:)
        return unless ticket.active?
        return unless analysis["priority"] == "low"
        return unless analysis["sentiment"].in?(AUTO_CLOSABLE_SENTIMENTS)
        return unless analysis["category"] == "information_request"
        return unless analysis["recommended_response"].present?

        Decision.new(
          outcome: :auto_close,
          severity: 10,
          attributes: {
            status: :closed,
            resolution_response: analysis.fetch("recommended_response"),
            closed_by_user: nil
          }
        )
      end
    end
  end
end

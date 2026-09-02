class SupportTicketAutoClosureRules
  AUTO_CLOSABLE_SENTIMENTS = %w[neutral good].freeze

  def initialize(ticket:, analysis:)
    @ticket = ticket
    @analysis = analysis
  end

  def eligible?
    @ticket.active? &&
      @analysis["priority"] == "low" &&
      @analysis["sentiment"].in?(AUTO_CLOSABLE_SENTIMENTS) &&
      @analysis["category"] == "information_request" &&
      @analysis["recommended_response"].present?
  end
end

class AnalyzeSupportTicketJob < ApplicationJob
  retry_on SupportTicketAnalyzer::Error, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(ticket_id)
    ticket = SupportTicket.find(ticket_id)
    analysis = SupportTicketAnalyzer.new.analyze(ticket)
    attributes = analysis

    if SupportTicketAutoClosureRules.new(ticket:, analysis:).eligible?
      attributes = analysis.merge(status: :closed, resolution_response: analysis.fetch("recommended_response"), closed_by_user: nil)
    end

    ticket.update!(attributes)
  end
end

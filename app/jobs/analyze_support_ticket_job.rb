class AnalyzeSupportTicketJob < ApplicationJob
  retry_on SupportTicketAnalyzer::Error, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(ticket_id)
    ticket = SupportTicket.find(ticket_id)
    analysis = SupportTicketAnalyzer.new.analyze(ticket)
    attributes = analysis

    if ticket.active? && auto_close?(analysis)
      attributes = analysis.merge(status: :closed, resolution_response: analysis.fetch("recommended_response"), closed_by_user: nil)
    end

    ticket.update!(attributes)
  end

  private

  def auto_close?(analysis)
    analysis.fetch("priority") == "low" &&
      analysis.fetch("sentiment").in?(%w[neutral good]) &&
      analysis.fetch("category") == "information_request" &&
      analysis.fetch("recommended_response").present?
  end
end

class AnalyzeSupportTicketJob < ApplicationJob
  retry_on SupportTicketAnalyzer::Error, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(ticket_id)
    ticket = SupportTicket.find(ticket_id)
    analysis = SupportTicketAnalyzer.new.analyze(ticket)
    SupportTicketTriage::Processor.new(ticket:, analysis:).call
  end
end

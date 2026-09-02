module SupportTicketTriage
  class DecisionExecutor
    def call(ticket:, analysis:, decision:)
      ticket.update!(analysis.merge(decision.attributes))
    end
  end
end

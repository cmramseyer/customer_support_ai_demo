module SupportTicketTriage
  class Processor
    def initialize(ticket:, analysis:, rule_checker: RuleChecker.new, decision_executor: DecisionExecutor.new)
      @ticket = ticket
      @analysis = analysis
      @rule_checker = rule_checker
      @decision_executor = decision_executor
    end

    def call
      @ticket.with_lock do
        decision = @rule_checker.call(ticket: @ticket, analysis: @analysis)
        @decision_executor.call(ticket: @ticket, analysis: @analysis, decision:)
        decision
      end
    end
  end
end

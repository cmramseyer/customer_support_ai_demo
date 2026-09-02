module SupportTicketTriage
  class RuleChecker
    RULES = [ Rules::AutoCloseInformationRequest.new ].freeze

    def initialize(rules: RULES)
      @rules = rules
    end

    def call(ticket:, analysis:)
      decisions = @rules.filter_map { |rule| rule.call(ticket:, analysis:) }
      return Decision.no_change if decisions.empty?

      highest_severity = decisions.map(&:severity).max
      highest_priority_decisions = decisions.select { |decision| decision.severity == highest_severity }
      return Decision.no_change if highest_priority_decisions.map(&:outcome).uniq.many?

      highest_priority_decisions.first
    end
  end
end

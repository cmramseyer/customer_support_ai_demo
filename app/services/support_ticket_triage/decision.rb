module SupportTicketTriage
  Decision = Data.define(:outcome, :severity, :attributes) do
    def self.no_change
      new(outcome: :no_change, severity: 0, attributes: {})
    end
  end
end

class AddAnalysisFieldsToSupportTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :support_tickets, :priority, :integer
    add_column :support_tickets, :problem, :string
    add_column :support_tickets, :category, :string
    add_column :support_tickets, :related_tickets, :integer, array: true, null: false, default: []
    add_column :support_tickets, :recommended_action, :string
    add_column :support_tickets, :recommended_response, :string
    add_column :support_tickets, :sentiment, :string

    add_check_constraint :support_tickets, "priority IN (0, 1, 2) OR priority IS NULL", name: "support_tickets_priority_valid"
  end
end

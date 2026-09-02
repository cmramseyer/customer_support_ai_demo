class AddResolutionToSupportTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :support_tickets, :resolution_response, :string
    add_reference :support_tickets, :closed_by_user, foreign_key: { to_table: :users }
  end
end

class CreateSupportTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :support_tickets do |t|
      t.references :order, null: false, foreign_key: true
      t.text :comment, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :support_tickets, "status IN (0, 1)", name: "support_tickets_status_valid"
  end
end

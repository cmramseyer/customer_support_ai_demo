class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.string :payment_method, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_check_constraint :orders, "quantity BETWEEN 1 AND 99", name: "orders_quantity_between_1_and_99"
    add_check_constraint :orders, "payment_method IN ('cash', 'credit_card', 'gift_card')", name: "orders_payment_method_valid"
    add_check_constraint :orders, "status IN (0, 1)", name: "orders_status_valid"
  end
end

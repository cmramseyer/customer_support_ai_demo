class AddModerationToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :status, :integer, default: 0, null: false
    add_check_constraint :comments, "status IN (0, 1, 2)", name: "comments_status_valid"

    add_column :users, :moderated_comments_count, :integer, default: 0, null: false
    add_check_constraint :users, "moderated_comments_count >= 0", name: "users_moderated_comments_count_nonnegative"
  end
end

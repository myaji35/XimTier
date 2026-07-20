# frozen_string_literal: true

class AddSuspensionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :suspended_at, :datetime
    add_column :users, :suspension_reason, :string
    add_index :users, :suspended_at
  end
end

class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan_code, null: false
      t.integer :amount, null: false
      t.string :currency, null: false, default: "KRW"
      t.string :status, null: false, default: "pending"
      t.string :payment_id, null: false
      t.string :portone_tx_id
      t.string :payment_method
      t.datetime :paid_at
      t.datetime :failed_at
      t.text :failure_reason
      t.json :raw_response, default: {}

      t.timestamps
    end

    add_index :payments, :payment_id, unique: true
    add_index :payments, :portone_tx_id, unique: true
    add_index :payments, :status
  end
end

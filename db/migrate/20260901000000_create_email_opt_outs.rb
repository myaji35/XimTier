class CreateEmailOptOuts < ActiveRecord::Migration[8.1]
  def change
    create_table :email_opt_outs do |t|
      t.string :email, null: false
      t.string :reason
      t.string :source, null: false
      t.datetime :created_at, null: false

      t.index :email, unique: true
    end
  end
end

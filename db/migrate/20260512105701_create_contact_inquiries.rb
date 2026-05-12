class CreateContactInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_inquiries do |t|
      t.string  :name,     null: false
      t.string  :email,    null: false
      t.string  :company
      t.integer :industry, default: 0, null: false
      t.text    :message,  null: false
      t.string  :source
      t.string  :locale,   default: "ko", null: false
      t.boolean :handled,  default: false, null: false

      t.timestamps
    end

    add_index :contact_inquiries, :email
    add_index :contact_inquiries, :handled
    add_index :contact_inquiries, :created_at
  end
end

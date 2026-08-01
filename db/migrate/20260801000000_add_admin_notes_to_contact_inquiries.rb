class AddAdminNotesToContactInquiries < ActiveRecord::Migration[8.1]
  def change
    add_column :contact_inquiries, :admin_notes, :text
  end
end

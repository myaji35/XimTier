class CreateDownloads < ActiveRecord::Migration[8.1]
  def change
    create_table :downloads do |t|
      t.string  :email,            null: false
      t.string  :name
      t.string  :company
      t.string  :role
      t.integer :asset,            default: 0, null: false
      t.string  :download_token,   null: false
      t.integer :downloaded_count, default: 0, null: false
      t.string  :locale,           default: "ko", null: false

      t.timestamps
    end

    add_index :downloads, :download_token, unique: true
    add_index :downloads, :email
    add_index :downloads, :created_at
  end
end

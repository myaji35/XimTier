class CreateDemoRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.text     :data_description
      t.datetime :preferred_at
      t.integer  :status,   default: 0, null: false
      t.datetime :scheduled_at
      t.string   :meeting_url
      t.text     :admin_notes
      t.string   :locale,   default: "ko", null: false
      t.string   :source

      t.timestamps
    end

    add_index :demo_requests, :status
    add_index :demo_requests, :created_at
  end
end

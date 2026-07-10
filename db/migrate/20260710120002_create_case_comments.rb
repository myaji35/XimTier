class CreateCaseComments < ActiveRecord::Migration[8.1]
  def change
    create_table :case_comments do |t|
      t.references :case_study, null: false, foreign_key: true
      t.string  :author_name, null: false
      t.text    :body,        null: false
      t.integer :status,      null: false, default: 0  # 0:pending 1:approved 2:hidden
      t.timestamps
    end
    add_index :case_comments, [:case_study_id, :status]
  end
end

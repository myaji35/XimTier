class CreateCaseLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :case_likes do |t|
      t.references :case_study, null: false, foreign_key: true
      t.string :visitor_token, null: false
      t.timestamps
    end
    add_index :case_likes, [:case_study_id, :visitor_token], unique: true
  end
end

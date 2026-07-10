class CreateCaseMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :case_media do |t|
      t.references :case_study, null: false, foreign_key: true
      t.integer :kind,        null: false, default: 0  # 0:youtube 1:pdf 2:html
      t.string  :title
      t.string  :youtube_url
      t.text    :embed_html
      t.text    :caption
      t.integer :position,    null: false, default: 0
      t.timestamps
    end
    add_index :case_media, [:case_study_id, :position]
  end
end

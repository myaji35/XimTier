class CreateCaseStudies < ActiveRecord::Migration[8.1]
  def change
    create_table :case_studies do |t|
      t.string  :slug,        null: false
      t.string  :title_ko,    null: false
      t.string  :title_en
      t.text    :summary_ko
      t.text    :summary_en
      t.text    :body_html_ko
      t.text    :body_html_en
      t.string  :industry
      t.boolean :published,   null: false, default: false
      t.datetime :published_at
      t.integer :likes_count, null: false, default: 0
      t.integer :position,    null: false, default: 0
      t.timestamps
    end
    add_index :case_studies, :slug, unique: true
    add_index :case_studies, [:published, :published_at]
    add_index :case_studies, :position
  end
end

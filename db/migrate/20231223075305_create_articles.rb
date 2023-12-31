class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :body, null: false, default: ""
      t.integer :word_count, null: false
      t.timestamps
    end
  end
end

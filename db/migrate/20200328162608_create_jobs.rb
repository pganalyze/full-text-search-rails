class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.string :source, null: false
      t.string :source_id, null: false
      t.string :title, null: false
      t.string :url
      t.text :description, null: false
      t.timestamp :posted_at, null: false
      t.timestamps
      t.index %i[source source_id], unique: true
    end
  end
end

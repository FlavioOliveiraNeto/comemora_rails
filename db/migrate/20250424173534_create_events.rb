class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.string :location
      t.references :admin, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

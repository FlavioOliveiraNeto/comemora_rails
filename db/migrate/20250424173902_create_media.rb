class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.references :user, foreign_key: true
      t.text :file_data

      t.timestamps
    end
  end
end

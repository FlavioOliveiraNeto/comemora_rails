class CreateEventMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :event_media do |t|
      t.references :event, foreign_key: true
      t.references :medium, foreign_key: true

      t.timestamps
    end
  end
end

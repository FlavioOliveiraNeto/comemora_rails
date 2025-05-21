class AddColumnDescriptionAndRemoveColumnFileDataFromMedia < ActiveRecord::Migration[5.2]
  def change
    remove_column :media, :file_data
    add_column :media, :description, :string
  end
end

class AddStatusToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :status, :integer, default: 0
    add_index :events, :status
  end
end

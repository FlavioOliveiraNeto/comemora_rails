class RenameJwtDenylistsToJwtDenylist < ActiveRecord::Migration[7.0]
  def change
    rename_table :jwt_denylists, :jwt_denylist
  end
end
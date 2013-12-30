class RenameColumnMetaToOutlineOnDetails < ActiveRecord::Migration
  def self.up
    rename_column :details, :meta_id, :outline_id
  end
end

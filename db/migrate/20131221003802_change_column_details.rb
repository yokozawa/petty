class ChangeColumnDetails < ActiveRecord::Migration
  def self.up
    rename_column :details, :user_id_id, :user_id
  end
end

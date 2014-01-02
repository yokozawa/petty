class AddSignOnDetails < ActiveRecord::Migration
  def change
    add_column :details, :sign, :boolean, :after => :user_id
  end
end

class AddColumnCreatedByOnDetails < ActiveRecord::Migration
  def change
    add_column :details, :created_by, :integer, :after => :created_at
  end
end

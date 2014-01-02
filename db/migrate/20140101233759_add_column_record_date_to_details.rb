class AddColumnRecordDateToDetails < ActiveRecord::Migration
  def up
    add_column :details, :record_at, :datetime, :after => :amount
  end
  def down
    remove_column :details, :record_at
  end
end

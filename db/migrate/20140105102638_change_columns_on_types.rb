class ChangeColumnsOnTypes < ActiveRecord::Migration
  def change
    change_column(:types, :cutoff_at, :integer)
    rename_column(:types, :cutoff_at, :cutoff_day)
    change_column(:types, :payment_at, :integer)
    rename_column(:types, :payment_at, :payment_day)
  end
end

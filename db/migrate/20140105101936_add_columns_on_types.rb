class AddColumnsOnTypes < ActiveRecord::Migration
  def change
    add_column :types, :is_card, :boolean, :after => :label
    add_column :types, :cutoff_at, :datetime, :after => :is_card
    add_column :types, :payment_at, :datetime, :after => :cutoff_at
  end
end

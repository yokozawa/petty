class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.references :user, index: true
      t.text :label
      t.boolean :deleted
      t.string :timestamps

      t.timestamps
    end
  end
end

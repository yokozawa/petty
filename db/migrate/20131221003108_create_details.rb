class CreateDetails < ActiveRecord::Migration
  def change
    create_table :details do |t|
      t.references :user_id, index: true
      t.integer :amount
      t.text :desc
      t.references :type, index: true
      t.references :meta, index: true
      t.boolean :deleted
      t.string :timestamps

      t.timestamps
    end
  end
end

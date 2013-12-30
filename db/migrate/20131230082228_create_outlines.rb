class CreateOutlines < ActiveRecord::Migration
  def change
    create_table :outlines do |t|
      t.references :user, index: true
      t.text :label
      t.boolean :deleted
      t.string :timestamps

      t.timestamps
    end
  end
end

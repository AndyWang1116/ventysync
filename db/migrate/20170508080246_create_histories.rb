class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.string :sync_to, null: false
      t.string :setion, null: false
      t.string :action, null: false
      t.text :message, null: false

      t.timestamps null: false
    end

    add_index :histories, :action
  end
end

class CreateSyncCheckers < ActiveRecord::Migration
  def change
    create_table :sync_checkers do |t|
      t.datetime :last_new_product_synced
      t.datetime :last_edited_product_synced

      t.timestamps null: false
    end
  end
end

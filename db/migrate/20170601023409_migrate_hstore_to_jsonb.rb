class MigrateHstoreToJsonb < ActiveRecord::Migration
  def up
    rename_column :histories, :message, :message_hstore
    add_column    :histories, :message, :jsonb, default: {}, null: false, index: { using: 'gin' }
    execute       'UPDATE "histories" SET "message" = json_object(hstore_to_matrix("message_hstore"))::jsonb'
    remove_column :histories, :message_hstore
  end

  def down
    rename_column :histories, :message, :message_jsonb
    add_column    :histories, :message, :hstore, default: {}, null: false, index: { using: 'gin' }
    execute       'UPDATE "histories" SET "message" = (SELECT hstore(key, value) FROM jsonb_each_text("message_jsonb"))'
    remove_column :histories, :message_jsonb
  end
end

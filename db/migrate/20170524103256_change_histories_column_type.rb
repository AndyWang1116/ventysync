class ChangeHistoriesColumnType < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    change_column :histories, :message, 'hstore USING CAST(message AS hstore)'
    add_index :histories, :message, using: :gin
  end
end

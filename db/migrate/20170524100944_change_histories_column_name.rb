class ChangeHistoriesColumnName < ActiveRecord::Migration
  def change
    rename_column :histories, :setion, :section
  end
end

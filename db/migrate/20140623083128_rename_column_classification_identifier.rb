class RenameColumnClassificationIdentifier < ActiveRecord::Migration
  def change
    rename_column :classifications, :classifiation_identifier, :classification_identifier
    remove_index :classifications, :name => 'classifications_index1'
    add_index :classifications, [:classification_identifier, :classification_type_id], :name => 'classifications_index1'
  end
end

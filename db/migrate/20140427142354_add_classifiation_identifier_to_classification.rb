class AddClassifiationIdentifierToClassification < ActiveRecord::Migration
  def change
    add_column :classifications, :classifiation_identifier, :string
    add_index :classifications, [:classifiation_identifier, :classification_type_id], :name => 'classifications_index1'
  end
end

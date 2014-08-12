class AddColumnClassificationsGroupIdentifier < ActiveRecord::Migration
  def change
    add_column :classifications, :group_identifier, :string
  end
end

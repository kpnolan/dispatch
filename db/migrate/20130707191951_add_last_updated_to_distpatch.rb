class AddLastUpdatedToDistpatch < ActiveRecord::Migration
  def change
    add_column :distpatches, :last_updated, :datetime, null: false
  end
end

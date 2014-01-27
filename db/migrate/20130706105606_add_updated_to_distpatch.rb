class AddUpdatedToDistpatch < ActiveRecord::Migration
  def change
    add_column :distpatches, :updated, :datetime
  end
end

class RemoveSummaryFromDistpatch < ActiveRecord::Migration
  def change
    remove_column :distpatches, :summary
    remove_column :distpatches, :tag
    remove_column :distpatches, :title
    remove_column :distpatches, :content
  end
end

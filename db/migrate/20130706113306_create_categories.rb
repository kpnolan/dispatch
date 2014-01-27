class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :abbrev, limit: 3
      t.string :label

      t.timestamps
    end
  end
end

class CreateDistpatches < ActiveRecord::Migration
  def change
    create_table :distpatches do |t|
      t.string :tag, limit: 63
      t.string :title
      t.references :category, index: true
      t.string :summary
      t.datetime :published
      t.string :content
      t.float :point_lat
      t.float :point_long

      t.timestamps
    end
  end
end

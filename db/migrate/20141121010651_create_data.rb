class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.string :key
      t.string :value

      t.timestamps
    change_column :data, :value, :text
    end
  end
end

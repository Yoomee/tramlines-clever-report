class CreateCleverFilters < ActiveRecord::Migration
  
  def self.up
    create_table :clever_filters do |t|
      t.string :association_name
      t.string :name
      t.text :args
      t.integer :report_id
      t.timestamps
    end
  end

  def self.down
    drop_table :clever_filters
  end
  
end

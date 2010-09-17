class CreateCleverReports < ActiveRecord::Migration
  
  def self.up
    create_table :clever_reports do |t|
      t.string :name      
      t.string :class_name
      t.text :field_names
      t.timestamps
    end
  end

  def self.down
    drop_table :clever_reports
  end
  
end

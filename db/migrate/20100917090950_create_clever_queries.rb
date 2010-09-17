class CreateCleverQueries < ActiveRecord::Migration
  
  def self.up
    create_table :clever_queries do |t|
      t.string :name
      t.text :args
      t.integer :report_id      
      t.timestamps
    end
  end

  def self.down
    drop_table :clever_queries
  end
  
end

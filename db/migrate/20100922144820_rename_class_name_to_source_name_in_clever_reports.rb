class RenameClassNameToSourceNameInCleverReports < ActiveRecord::Migration
  def self.up
    rename_column :clever_reports, :class_name, :source_name
  end

  def self.down
    rename_column :clever_reports, :source_name, :class_name
  end
end

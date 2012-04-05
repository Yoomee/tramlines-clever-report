class AddMemberIdAndRunAtToCleverReports < ActiveRecord::Migration
  def self.up
    add_column :clever_reports, :created_by_id, :integer
    add_column :clever_reports, :last_edited_at, :datetime
    add_column :clever_reports, :last_edited_by_id, :integer
    add_column :clever_reports, :last_run_at, :datetime
    add_column :clever_reports, :last_run_by_id, :integer
  end

  def self.down
    remove_column :clever_reports, :created_by_id
    remove_column :clever_reports, :last_edited_at
    remove_column :clever_reports, :last_edited_by_id
    remove_column :clever_reports, :last_run_at
    remove_column :clever_reports, :last_run_by_id
  end
end

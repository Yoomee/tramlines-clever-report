module HasCleverReports
  
  def self.included(klass)
    klass.cattr_accessor :associations_for_clever_reports
  end
  
end
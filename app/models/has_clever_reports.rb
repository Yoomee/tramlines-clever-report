module HasCleverReports
  
  def self.included(klass)
    klass.cattr_accessor :associations_for_clever_reports
    klass.cattr_accessor :clever_fields    
    klass.clever_fields ||= []
  end
  
end
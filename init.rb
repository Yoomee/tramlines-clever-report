# Include hook code here
ActiveRecord::Base.class_eval do
  
  class << self
    
    def has_clever_reports_with(*args)
      send(:include, HasCleverReports)
      self.associations_for_clever_reports = args.flatten.collect(&:to_s)
      associations_for_clever_reports.each do |association|
        define_method "number_of_#{association}" do
          send(association).size
        end
      end
    end
    alias_method :has_clever_reports, :has_clever_reports_with
    
    def has_clever_filter(name, options = {})
      
    end
    
  end
  
end

%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')
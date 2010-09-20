# Include hook code here
ActiveRecord::Base.class_eval do
  
  class << self
    
    def has_clever_reports_with(*args)
      send(:include, HasCleverReports)
      self.associations_for_clever_reports = args.flatten.collect(&:to_s)
      associations_for_clever_reports.each do |association_name|
        cattr_accessor("clever_stats_for_#{association_name}")
        self.send("clever_stats_for_#{association_name}=", [])
        # define_method "number_of_#{association}" do
        #   send(association).size
        # end
      end
    end
    alias_method :has_clever_reports, :has_clever_reports_with
    
    def has_clever_filter(name, options = {})
      
    end

    def has_clever_fields_blacklist(blacklist = [])
      self.clever_fields = column_names - (blacklist << "id")
    end
    
    def has_clever_stat_on(association_name, stat_name, &block)
      stat_name = "clever_stat_#{stat_name.downcase.gsub(/\s/, '_')}"
      self.send("clever_stats_for_#{association_name}") << stat_name
      define_method(stat_name, &block)
    end
    
  end
  
end

%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')
ActiveRecord::Base.class_eval do  
  
  attr_accessor :clever_report
  
  class << self
    
    attr_reader :clever_fields, :clever_field_labels
    
    def has_clever_fields(*fields)
      @clever_field_labels = {}
      @clever_fields = []
      fields.each do |field|
        name, label = (field.is_a?(Array) ? field : [field, field.to_s.humanize])
        @clever_field_labels[name.to_s] = label.to_s
        @clever_fields << name.to_s
      end
    end

    def custom_clever_options
      @custom_clever_options ||= {}
    end
    
    def has_clever_options_for(field_name, collection = nil, &block)
      @custom_clever_options ||= {}
      @custom_clever_options[field_name] = block_given? ? block : collection
    end
    
    def has_clever_reports_with(*args)
      send(:include, HasCleverReports)
      self.associations_for_clever_reports = args.flatten.collect(&:to_s)
      associations_for_clever_reports.each do |association_name|
        cattr_accessor("clever_stats_for_#{association_name}")
        self.send("clever_stats_for_#{association_name}=", [])
      end
    end
    alias_method :has_clever_reports, :has_clever_reports_with
    
    def has_clever_stat_on(association_name, stat_name, &block)
      stat_name = "clever_stat_#{stat_name.downcase.gsub(/\s/, '_')}"
      self.send("clever_stats_for_#{association_name}") << stat_name
      define_method(stat_name, &block)
    end
    
  end
  
  def clever_association(association_name)
    eval "#{association_name}.#{clever_report.filters.call_string_for_association(association_name)}"
  end
  
  
end

%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')
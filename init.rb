ActiveRecord::Base.class_eval do  
  
  attr_accessor :clever_report
  
  class << self
    
    attr_reader :clever_fields, :clever_field_labels, :clever_fields_only_results
    
    def has_clever_fields(*fields)
      options = fields.extract_options!
      @clever_field_labels = {}
      @clever_fields = []
      add_clever_field_labels(fields)
      @clever_fields = fields.collect {|field| get_clever_field_name(field)}
      @clever_fields_only_results = (options[:only_for_results] || []).collect {|field| field.is_a?(Array) ? field[0].to_s : field.to_s}
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
      cattr_accessor(:clever_stats)
      self.clever_stats = ActiveSupport::OrderedHash.new
      self.associations_for_clever_reports = args.flatten.collect(&:to_s)
      associations_for_clever_reports.each do |association_name|
        self.clever_stats[association_name] = ActiveSupport::OrderedHash.new
      end
    end
    alias_method :has_clever_reports, :has_clever_reports_with
    
    def has_clever_stat_on(association_name, stat_name, options = {}, &block)
      stat_label = options[:label] || stat_name.to_s.humanize
      self.clever_stats[association_name.to_s]["clever_stat_#{stat_name}"] = stat_label
      define_method("clever_stat_#{stat_name}", &block)
    end
    
    private
    def add_clever_field_labels(fields)
      @custom_clever_options ||= {}
      @clever_field_labels ||= {}
      fields.each do |field|
        if field.is_a?(Array)
          name, label = field.collect(&:to_s)
        else
          name, label = [field.to_s, field.to_s.humanize]
        end
        if association = reflect_on_association(name.to_sym)
          if association.belongs_to? && @custom_clever_options[association.primary_key_name.to_s].nil?
            name = association.primary_key_name.to_s
            collection = association.klass.all.sort_by(&:to_s).inject(ActiveSupport::OrderedHash.new) {|out, c| out[c.to_s] = c.id; out}
            @custom_clever_options[name] = collection
          end
        end
        @clever_field_labels[name] = label
      end      
    end
    
    def get_clever_field_name(field_or_array)
      if field_or_array.is_a?(Array)
        name = field_or_array.first
      else
        name = field_or_array
      end
      if association = reflect_on_association(name.to_sym)
        if association.belongs_to?
          name = association.primary_key_name
        end
      end
      name.to_s
    end
    
  end
  
  def clever_association(association_name)
    eval "#{association_name}.#{clever_report.call_string_for_association(association_name)}"
  end
  
  
end

%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')
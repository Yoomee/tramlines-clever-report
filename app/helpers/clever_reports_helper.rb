module CleverReportsHelper
  
  def clever_label_name(field_name)
    field_name.gsub(/^clever_stat_/, '').humanize
  end
  
  def model_options_for_clever_report
    options_for_clever_report(CleverReport::REPORTABLE_MODELS, :method => "pluralize")
  end
  
  def options_for_clever_report(collection, options = {})
    options.reverse_merge!(:method => "humanize")
    options_hash = ActiveSupport::OrderedHash.new
    collection.each do |name|
      label_name = clever_label_name(name)
      label_name = "Crm Id" if label_name == "Crm"
      options_hash[label_name] = name
    end
    options_hash
  end
  
  def options_string_for_clever_report(collection, options = {})
    options_for_select(options_for_clever_report(collection, options))
  end
  
  def options_for_clever_field_names(association_name, options = {})
    klass = association_name.singularize.classify.constantize
    klass.clever_fields.inject("") do |out, field_name|
      if klass.custom_clever_options.keys.collect(&:to_s).include?(field_name.to_s)
        column_type = "custom_select"
      else
        column_type = klass.columns.detect{|col| col.name == field_name}.type.to_s
      end
      tag_options = {:class => "clever_type_#{column_type}", :value => field_name}
      tag_options[:selected] = "selected" if options[:selected] == field_name
      out << content_tag(:option, field_name.humanize, tag_options)
    end
  end
  
end
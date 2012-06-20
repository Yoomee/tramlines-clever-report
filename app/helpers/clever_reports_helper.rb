module CleverReportsHelper
  
  def clever_label_name(field_name, method = nil)
    CleverReport::clever_label_name(field_name,method)
  end
  
  def model_options_for_clever_report
    options_for_clever_report(CleverReport::REPORTABLE_MODELS.sort, :method => "pluralize")
  end
  
  def options_for_clever_report(collection, options = {})
    options_hash = ActiveSupport::OrderedHash.new
    collection.each do |name|
      options_hash[clever_label_name(name, options[:method])] = name
    end
    options_hash
  end
  
  def options_for_possible_clever_field_names(report)
    options_hash = ActiveSupport::OrderedHash.new
    report.possible_field_names.each do |name|
      options_hash[report.clever_label_name(name)] = name
    end
    options_hash
  end  
  
  def options_string_for_clever_report(collection, options = {})
    options_for_select(options_for_clever_report(collection, options))
  end

  def criterion_input_type(criterion)
    case
    when (criterion.in? %w{is_today is_yesterday})
      "hidden"
    when (criterion.in? %w{is_between is_between_inclusive})
      "double_input"
    when (criterion.in? %w{is_in_the_last is_in_the_next})
      "date_range"
    else
      "input"
    end
  end

  def options_for_clever_criteria(collection, options = {})
    collection.inject("") do |out, criterion|
      label_name, value = criterion.is_a?(Array) ? criterion : [criterion, criterion]
      tag_options = {:class => "clever_type_#{criterion_input_type(criterion)}", :value => value}
      tag_options[:selected] = "selected" if options[:selected] == value
      out << content_tag(:option, clever_label_name(label_name), tag_options)
    end
  end
  
  def options_for_clever_field_names(association_name, options = {})
    klass = association_name.to_s == "addresses" ? Location : association_name.classify.constantize
    klass.clever_fields.inject("") do |out, field_name|
      if klass.custom_clever_options.keys.collect(&:to_s).include?(field_name.to_s)
        column_type = "custom_select"
      elsif column = klass.columns.detect{|col| col.name == field_name}
        column_type = column.type.to_s
      elsif field_name == "tag_list"
        column_type = "tag_list"        
      else
        column_type = "string"
      end
      tag_options = {:class => "clever_type_#{column_type}", :value => field_name}
      tag_options[:selected] = "selected" if options[:selected] == field_name
      out << content_tag(:option, klass.clever_field_labels[field_name.to_s], tag_options)
    end
  end
  
end

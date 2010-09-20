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
  
end
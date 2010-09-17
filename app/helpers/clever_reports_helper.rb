module CleverReportsHelper

  def field_name_options_for_clever_report(report)
    options_for_clever_report(:collection => report.possible_field_names, :method => "humanize")
  end
  
  def model_options_for_clever_report
    options_for_clever_report(:collection => CleverReport::REPORTABLE_MODELS, :method => "pluralize")
  end
  
  def options_for_clever_report(options = {})
    return [] if options[:collection].empty?
    options_hash = ActiveSupport::OrderedHash.new
    options[:collection].each do |name|
      options_hash[name.send(options[:method])] = name
    end
    options_hash
  end
  
end
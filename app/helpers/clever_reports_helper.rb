module CleverReportsHelper
  
  def model_options_for_clever_report
    options_for_clever_report(CleverReport::REPORTABLE_MODELS, :method => "pluralize")
  end
  
  def options_for_clever_report(collection, options = {})
    options.reverse_merge!(:method => "humanize")
    options_hash = ActiveSupport::OrderedHash.new
    collection.each do |name|
      options_hash[name.send(options[:method])] = name
    end
    options_hash
  end
  
end
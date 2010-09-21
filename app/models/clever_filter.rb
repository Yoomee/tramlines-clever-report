class CleverFilter < ActiveRecord::Base
  
  belongs_to :report, :class_name => "CleverReport"
  
  validates_presence_of :criterion
  serialize :args
  
  def args
    read_attribute(:args).is_a?(Array) ? read_attribute(:args) : [read_attribute(:args)]
  end
  
  def call_string
    return name if args.nil?
    "#{name}('#{args.join("', '")}')"
  end
  
  def clever_field_names
    return [] if association_name.blank?
    association_name.singularize.classify.constantize.clever_fields
  end
  
  def has_association_name?
    !association_name.blank? && !(association_name.underscore.singularize == report.class_name.underscore)
  end
  
  def name
    name = has_association_name? ? "#{association_name}_" : ""
    name << "#{field_name}_" unless field_name.blank?
    name << "#{criterion}"
  end
  
end
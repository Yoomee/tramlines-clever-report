class CleverFilter < ActiveRecord::Base
  
  belongs_to :report, :class_name => "CleverReport"
  
  attr_accessor :field_name
  attr_accessor :criterion
  
  validates_presence_of :name
  serialize :args
  
  before_validation :set_name
  
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
  
  private
  def set_name
    unless field_name.blank? || criterion.blank?
      name = has_association_name? ? "#{association_name}_" : ""
      self.name = name << "#{field_name}_#{criterion}"
    end
  end
  
end
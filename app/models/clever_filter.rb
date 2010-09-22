class CleverFilter < ActiveRecord::Base
  
  belongs_to :report, :class_name => "CleverReport"
  
  validates_presence_of :criterion
  serialize :args
  
  def args
    read_attribute(:args).is_a?(Array) ? read_attribute(:args) : [read_attribute(:args)]
  end
  
  def call_string
    # %w{is_in_the_next is_in_the_last is_today is_yesterday}
    out = has_association_name? ? "#{association_name}_" : ""
    out << "#{field_name}_" unless field_name.blank?
    case criterion
      when "is_today"
        out << "is_between(#{Date.yesterday}, #{Date.tomorrow})"
      when "is_yesterday"
        out << "is_between(#{2.days.ago.to_date}, #{Date.today})"
      when "is_in_the_next"
        out << "is_between(#{Date.yesterday}, #{args[0].to_i.send(args[1]).from_now.to_date})"
      when "is_in_the_last"
        out << "is_between(#{args[0].to_i.send(args[1]).ago.to_date}, #{Date.tomorrow})"
      else
        args.nil? ? out : out << "#{criterion}('#{args.join("', '")}')"
    end
  end
  alias_method :name, :call_string
  
  def clever_field_names
    return [] if association_name.blank?
    association_name.singularize.classify.constantize.clever_fields
  end
  
  def has_association_name?
    !association_name.blank? && !(association_name.underscore.singularize == report.source_name.underscore)
  end
  # 
  # def name(custom_field_name = field_name, custom_criterion = criterion)
  #   name = has_association_name? ? "#{association_name}_" : ""
  #   name << "#{custom_field_name}_" unless custom_field_name.blank?
  #   name << "#{custom_criterion}"
  # end
  
end
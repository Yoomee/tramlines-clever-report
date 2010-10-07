class CleverFilter < ActiveRecord::Base
  
  belongs_to :report, :class_name => "CleverReport"
  
  validates_presence_of :criterion
  serialize :args

  delegate :source_name, :to => :report
  delegate :possible_field_names, :to => :report

  STRING_CRITERIA = %w{is_equal_to is_not_equal_to contains does_not_contain begins_with does_not_begin_with ends_with does_not_end_with is_not_set}
  NUMBER_CRITERIA = %w{is_equal_to is_less_than is_less_than_or_equal_to is_greater_than is_greater_than_or_equal_to is_between is_between_inclusive is_not_set}
  DATE_CRITERIA = %w{is_on_or_before is_before is_on_or_after is_between is_between_inclusive is_in_the_next is_in_the_last is_today is_yesterday is_not_set}
  BOOLEAN_CRITERIA = [['Is true','is'], ['Is false','is_not']]
  DATE_DURATIONS = ['days', 'weeks', 'months', 'years']

  COMPARISON_CONDITIONS = {
    :equals => [:is_equal_to],
    :does_not_equal => [:is_not_equal_to],
    :less_than => [:is_less_than, :is_before],
    :less_than_or_equal_to => [:is_less_than_or_equal_to, :is_on_or_before],
    :greater_than => [:is_greater_than, :is_after],
    :greater_than_or_equal_to => [:is_greater_than_or_equal_to, :is_on_or_after]
  }
  
  WILDCARD_CONDITIONS = {
    :not_like => [:does_not_contain]
  }

  BOOLEAN_CONDITIONS = {
    :null => [:is_not_set]
  }
  
  ALL_CONDITIONS = COMPARISON_CONDITIONS.merge(WILDCARD_CONDITIONS).merge(BOOLEAN_CONDITIONS)
  
  def args
    read_attribute(:args).is_a?(Array) ? read_attribute(:args) : [read_attribute(:args)]
  end
  
  def association_name
    read_attribute(:association_name).blank? ? source_name.pluralize.downcase : read_attribute(:association_name)
  end
  
  def call_string
    out = has_association_name? ? "#{association_name}_" : ""
    out << "#{field_name}_" unless field_name.blank?
    case criterion
      when "is_today"
        out << "is_between('#{Date.yesterday}', '#{Date.tomorrow}')"
      when "is_yesterday"
        out << "is_between('#{2.days.ago.to_date}', '#{Date.today}')"
      when "is_in_the_next"
        out << "is_between('#{Date.yesterday}', '#{args[0].to_i.send(args[1]).from_now.to_date}')"
      when "is_in_the_last"
        out << "is_between('#{args[0].to_i.send(args[1]).ago.to_date}', '#{Date.tomorrow}')"
      else
        args.nil? ? out : out << "#{core_criterion}('#{core_args.join("', '")}')"
    end
  end
  alias_method :name, :call_string
  
  def clever_field_names
    return [] if association_name.blank?
    association_name.singularize.classify.constantize.clever_fields
  end
  
  def core_args
    field_type.in?(%w{date time dateime}) ? args.collect {|a| Date.strptime(a, '%d/%m/%Y')} : args
  end
  
  def core_criterion
    return criterion if ALL_CONDITIONS.keys.include?(criterion.to_sym)
    ALL_CONDITIONS.each do |name, aliases|
      return name if aliases.include?(criterion.to_sym)
    end
    criterion
  end

  def criterion
    return read_attribute(:criterion) unless read_attribute(:criterion).blank? 
    report.nil? ? nil : possible_field_names.first
  end

  def criteria_options
    case field_type
    when "date" || "time" || "dateime"
      DATE_CRITERIA
    when "integer" || "float"
      NUMBER_CRITERIA
    when "boolean"
      BOOLEAN_CRITERIA
    when "custom_select"
      ["is", "is_not"]
    else
      STRING_CRITERIA
    end
  end
  
  def field_type
    return nil if association_name.blank? || field_name.blank?
    klass = association_name.classify.constantize
    return "custom_select" if klass.custom_clever_options.keys.collect(&:to_s).include?(field_name.to_s)
    klass.columns.detect{|col| col.name == field_name}.type.to_s
  end
  
  def has_association_name?
    !association_name.blank? && !(association_name.underscore.singularize == report.source_name.underscore)
  end
  
end
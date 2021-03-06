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
  CUSTOM_SELECT_CRITERIA = ["is", "is_not"]
  TAG_ID_CRITERIA = ['include', 'does_not_include']
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
  
  validate :enough_args_for_between_criteria
  
  def args
    read_attribute(:args).is_a?(Array) ? read_attribute(:args) : [read_attribute(:args)]
  end
  
  def association_class
    if assoc = source_name.constantize.reflect_on_association(association_name.to_sym)
      assoc.class_name.classify.constantize
    else
      association_name.classify.constantize
    end
  end
  
  def association_name
    read_attribute(:association_name).blank? ? source_name.underscore.pluralize.downcase : read_attribute(:association_name)
  end
  
  def call_string(include_association_name = true)
    out = has_association_name? && include_association_name ? "#{association_name}_" : ""
    if field_name == "tag_id"
      out << "tagging_#{'does_not_' if criterion=='does_not_include'}exists_with_tag_id(#{core_args.first})"
    elsif criterion == "contains"
      out << "regexp('#{field_name}', '#{core_args.join("|")}')"
    else
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
  end
  alias_method :name, :call_string
  
  def clever_field_names
    return [] if association_name.blank?
    association_class.clever_fields
  end
  
  def core_args
    if field_name.ends_with?('in_pence')
      args.collect {|pounds| (pounds.to_f * 100).round(2).to_i}
    else
      field_type.in?(%w{date time datetime}) ? args.collect {|a| Date.strptime(a, '%d/%m/%Y')} : args
    end
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
    when "date", "time", "datetime"
      DATE_CRITERIA
    when "integer", "float"
      NUMBER_CRITERIA
    when "boolean"
      BOOLEAN_CRITERIA
    when "custom_select"
      CUSTOM_SELECT_CRITERIA
    when "tag_id"
      TAG_ID_CRITERIA
    else
      STRING_CRITERIA
    end
  end
  
  def field_type
    return nil if association_name.blank? || field_name.blank?
    return "tag_id" if field_name == "tag_id"    
    return "custom_select" if association_class.custom_clever_options.keys.collect(&:to_s).include?(field_name.to_s)
    association_class.columns.detect{|col| col.name == field_name}.type.to_s
  end
  
  def has_association_name?
    !association_name.blank? && !(association_name.underscore.singularize == report.source_name.underscore)
  end
  
  private
  def enough_args_for_between_criteria
    if criterion.starts_with?('is_between')
      errors.add(:args, 'needs 2 arguments') if args.size < 2 || args.any?(&:blank?)
    end
  end
  
end
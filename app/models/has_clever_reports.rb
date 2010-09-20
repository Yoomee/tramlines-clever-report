module HasCleverReports
  
  STRING_FILTER_CRITERIA = %w{is_equal_to is_not_equal_to contains starts_with ends_with}
  NUMBER_FILTER_CRITERIA = %w{is_equal_to is_less_than is_greater_than is_between}
  DATE_FILTER_CRITERIA = %w{is_between is_in_the_next is_in_the_last is_on_or_before is_before is_on_or_after is_after is_today is_yesterday is_not_set}
  
  def self.included(klass)
    klass.cattr_accessor :associations_for_clever_reports
  end
  
end

module HasCleverReports
  
  # TODO: need implementing
  # NUMBER_FILTER_CRITERIA = %w{}
  # DATE_FILTER_CRITERIA = %w{is_in_the_next is_in_the_last is_today is_yesterday}

  # all conditions
  # STRING_FILTER_CRITERIA = %w{is_equal_to is_not_equal_to contains does_not_contain begins_with does_not_begin_with ends_with does_not_end_with}
  # NUMBER_FILTER_CRITERIA = %w{is_equal_to is_less_than is_less_than_or_equal_to is_greater_than is_greater_than_or_equal_to is_between is_not_set}
  # DATE_FILTER_CRITERIA = %w{is_between is_in_the_next is_in_the_last is_on_or_before is_before is_on_or_after is_after is_today is_yesterday is_not_set}
  
  #conditions tha work
  STRING_FILTER_CRITERIA = %w{is_equal_to is_not_equal_to contains does_not_contain begins_with does_not_begin_with ends_with does_not_end_with}
  NUMBER_FILTER_CRITERIA = %w{is_equal_to is_less_than is_less_than_or_equal_to is_greater_than is_greater_than_or_equal_to is_between is_between_inclusive is_not_set}
  DATE_FILTER_CRITERIA = %w{is_on_or_before is_before is_on_or_after is_between is_between_inclusive is_not_set}
  
  def self.included(klass)
    klass.cattr_accessor :associations_for_clever_reports
  end
  
end

require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class CleverFilterTest < ActiveSupport::TestCase
  
  should have_db_column(:field_name).of_type(:string)
  should have_db_column(:criterion).of_type(:string)  
  should have_db_column(:args).of_type(:text)
  
  should belong_to(:report)
  
  should validate_presence_of(:criterion)  
  
end

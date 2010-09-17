require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class CleverQueryTest < ActiveSupport::TestCase
  
  should have_db_column(:name).of_type(:string)
  should have_db_column(:args).of_type(:text)
  
  should belong_to(:report)
  
  should validate_presence_of(:name)
  
end

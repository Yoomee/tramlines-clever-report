require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class CleverReportTest < ActiveSupport::TestCase
  
  should have_db_column(:name).of_type(:string)
  should have_db_column(:source_name).of_type(:string)
  should have_db_column(:field_names).of_type(:text)  

  should have_many(:filters)
  
  should validate_presence_of(:name)
  
end

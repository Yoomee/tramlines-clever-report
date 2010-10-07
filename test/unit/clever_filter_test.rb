require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class CleverFilterTest < ActiveSupport::TestCase

  should have_db_column(:field_name).of_type(:string)
  should have_db_column(:criterion).of_type(:string)  
  should have_db_column(:args).of_type(:text)

  should belong_to(:report)

  should validate_presence_of(:criterion)

  context "on call to instance method call_string" do
    setup do
      @report = Factory.build(:clever_report, :source_name => 'Member')
    end
    
    should "return correct call_string for standard criteria" do
      @filter = Factory.build(:clever_filter, :report => @report, :association_name => 'members', :field_name => 'forename', :criterion => 'is_equal_to', :args => ['John'])
      assert_equal @filter.call_string, "forename_equals('John')"
    end
    
    should "return dynamically calculated call_string for criterion 'is_today'" do
      @filter = Factory.build(:clever_filter, :report => @report, :association_name => 'members', :field_name => 'created_at', :criterion => 'is_today')
      assert_equal @filter.call_string, "created_at_is_between('#{Date.yesterday}', '#{Date.tomorrow}')"
    end
    
    should "return dynamically calculated call_string for criterion 'is_yesterday'" do
      @filter = Factory.build(:clever_filter, :report => @report, :association_name => 'members', :field_name => 'created_at', :criterion => 'is_yesterday')
      assert_equal @filter.call_string, "created_at_is_between('#{2.days.ago.to_date}', '#{Date.today}')"
    end
    
    should "return dynamically calculated call_string for criterion 'is_in_the_next'" do
      @filter = Factory.build(:clever_filter, :report => @report, :association_name => 'members', :field_name => 'created_at', :criterion => 'is_in_the_next', :args => [2, "weeks"])
      assert_equal @filter.call_string, "created_at_is_between('#{Date.yesterday}', '#{2.weeks.from_now.to_date}')"
    end
    
    should "return dynamically calculated call_string for criterion 'is_in_the_last'" do
      @filter = Factory.build(:clever_filter, :report => @report, :association_name => 'members', :field_name => 'created_at', :criterion => 'is_in_the_last', :args => [3, "days"])
      assert_equal @filter.call_string, "created_at_is_between('#{3.days.ago.to_date}', '#{Date.tomorrow}')"
    end
    
  end  

end

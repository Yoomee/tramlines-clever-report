class CleverReport < ActiveRecord::Base

  REPORTABLE_MODELS = %w{Contact Donation Event Campaign}
  STEP_TITLES = ["Step 1: Choose source", "Step 2: Include Fields", "Step 3: Set filters"]
  
  has_many :queries, :class_name => "CleverQuery", :foreign_key => "report_id" do
    def call_string
      all.collect(&:call_string).join(".")
    end
  end
  
  serialize :field_names
  
  validates_presence_of :name
  validates_presence_of :class_name

  attr_accessor :step_num
  
  class << self

    def number_of_steps
      STEP_TITLES.size
    end
    
    def possible_field_names(class_name)
      class_name.constantize.column_names.reject! {|name| name.in? %w{id}}
    end    
    
  end

  def last_step?
    self.class::number_of_steps == step_num
  end
  
  def possible_field_names
    self.class::possible_field_names(class_name)
  end
  
  def results
    @results ||= get_results
  end
  
  def step_title
    STEP_TITLES[step_num - 1]
  end
  
  def to_s
    name
  end
  
  private
  def get_results
    named_scope_chain = queries.call_string
    class_name.constantize.instance_eval { eval named_scope_chain }
  end
  
end
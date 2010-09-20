class CleverReport < ActiveRecord::Base

  REPORTABLE_MODELS = %w{Contact Donation Event Campaign}
  STEP_TITLES = ["Step 1: Choose source", "Step 2: Include Fields", "Step 3: Set filters"]
  
  has_many :filters, :class_name => "CleverFilter", :foreign_key => "report_id" do
    def call_string
      all.collect(&:call_string).join(".")
    end
  end
  
  serialize :field_names
  
  accepts_nested_attributes_for :filters, :allow_destroy => true
  
  validates_presence_of :name
  validates_presence_of :class_name
  validates_uniqueness_of :name

  attr_writer :step_num
  
  class << self

    def number_of_steps
      STEP_TITLES.size
    end
    
    def possible_field_names(class_name)
      return [] if class_name.nil?
      class_name.constantize.clever_fields
    end
    
  end

  def association_names
    class_name.constantize::associations_for_clever_reports || []
  end

  def clever_stats_for(association_name)
    class_name.constantize.send("clever_stats_for_#{association_name}")
  end

  def field_names=(value)
    write_attribute(:field_names, value.reject(&:blank?))
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
  
  def step_num
    @step_num.try(:to_i) || 1
  end
  
  def step_title
    STEP_TITLES[step_num - 1]
  end
  
  def to_s
    name
  end
  
  private
  def get_results
    named_scope_chain = filters.call_string
    return class_name.constantize.all if named_scope_chain.blank?
    class_name.constantize.instance_eval { eval named_scope_chain }
  end
  
end
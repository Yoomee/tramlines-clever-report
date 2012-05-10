class CleverReport < ActiveRecord::Base

  REPORTABLE_MODELS = %w{Contact Donation Event Campaign}
  STEP_TITLES = ["Report name and source", "Include these fields in the results", "Apply these filters"]
  
  belongs_to :created_by, :class_name => "Member"
  belongs_to :last_edited_by, :class_name => "Member"
  belongs_to :last_run_by, :class_name => "Member"
    
  cattr_accessor :reportable_models
  
  has_many :filters, :class_name => "CleverFilter", :foreign_key => "report_id" do
    def call_string
      call_array.join(".")
    end
    
    def call_array
      all.collect(&:call_string)
    end
  end
  
  serialize :field_names
  
  accepts_nested_attributes_for :filters, :allow_destroy => true
  
  validates_presence_of :name
  validates_uniqueness_of :name

  attr_writer :step_num
  
  class << self

    def number_of_steps
      STEP_TITLES.size
    end
    
    def possible_field_names(source_name)
      return [] if source_name.nil?
      source_name.constantize.clever_fields
    end
    
  end

  def association_names
    source_name.constantize::associations_for_clever_reports || []
  end

  def source_name
    read_attribute(:source_name).blank? ? REPORTABLE_MODELS.first : read_attribute(:source_name)
  end

  def clever_stats_for(association_name)
    source_name.constantize.send("clever_stats_for_#{association_name}")
  end

  def field_names=(value)
    write_attribute(:field_names, value.reject(&:blank?))
  end

  def last_step?
    self.class::number_of_steps == step_num
  end
  
  def possible_field_names
    self.class::possible_field_names(source_name)
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
    return source_name.constantize.scoped_all if named_scope_chain.blank?
    named_scope_chain << ".group_by_id"
    source_name.constantize.instance_eval { eval named_scope_chain }
  end
  
end
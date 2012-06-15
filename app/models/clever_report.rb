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
    
    def clever_label_name(field_name, method = nil)
      label_name = clever_field_labels[field_name.to_s] || field_name.to_s.gsub(/^clever_stat_/, '')
      method ? label_name.send(method) : label_name.humanize
    end
    
  end
  
  def association_class_names
    source_name.constantize::associations_for_clever_reports.collect do |assoc_name|
      source_name.constantize.reflect_on_association(assoc_name.to_sym).class_name.pluralize.underscore
    end
  end

  def association_names
    source_name.constantize::associations_for_clever_reports || []
  end

  def source_class
    source_name.constantize
  end

  def source_name
    read_attribute(:source_name).blank? ? REPORTABLE_MODELS.first : read_attribute(:source_name)
  end

  def clever_field_name(field_name)
    if assoc = source_class.reflect_on_association(field_name.gsub(/_id$/, '').to_sym)
      field_name.gsub(/_id$/, '')
    else
      field_name.gsub(/_in_pence$/,'')
    end
  end

  def clever_stats_for(association_name)
    source_name.constantize.send("clever_stats_for_#{association_name}")
  end
  
  def fields_for_data_export
    field_names.collect do |field_name|
      {:field => clever_field_name(field_name), :label => self.class::clever_label_name(field_name)}
    end
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
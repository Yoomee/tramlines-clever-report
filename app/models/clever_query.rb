class CleverQuery < ActiveRecord::Base
  
  belongs_to :report, :class_name => "CleverReport"
  
  validates_presence_of :name
  serialize :args  
  
  def call_string
    return name if args.nil?
    "#{name}(#{args.join(', ')})"
  end
  
end
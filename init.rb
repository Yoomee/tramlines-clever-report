# Include hook code here
ActiveRecord::Base.class_eval do
  
  class << self
    
    def has_clever_query(name, options = {})
      
    end
    
  end
  
end

%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')
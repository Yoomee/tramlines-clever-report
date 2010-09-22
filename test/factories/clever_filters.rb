Factory.define(:clever_filter) do |f|
  f.association :report, :factory => :clever_report
  f.association_name 'members'
  f.field_name 'forename'
  f.criterion 'is_equal_to'
  f.args ['John']
end

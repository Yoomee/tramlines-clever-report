ActionController::Routing::Routes.draw do |map|

  map.resources :clever_reports, :as => 'reports'
  map.resources :clever_reports
 
end
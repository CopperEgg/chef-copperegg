# stop.rb resides in the copperegg cookbook
# but refers to the revealcloud service

include_recipe "copperegg::service"

service "revealcloud" do
  action :stop
end

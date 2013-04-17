# example recipe for managing copperegg probes
#
copperegg_probe "ChefProbe2" do
  provider "copperegg_probe"
  action :update
  probe_desc 'ChefProbe2'
  probe_dest "http://copperegg.com"
  type 'GET'
  stations ['dal','nrk']
end

copperegg_probe "Chef Probe3" do
  provider "copperegg_probe"
  action :delete
  probe_desc 'Chef Probe3'
  probe_dest "http://copperegg.com:80"
  type 'TCP'
end


copperegg_probe "Chef Probe3" do
  provider "copperegg_probe"
  action :enable
  probe_desc 'Chef Probe3'
  probe_dest "http://copperegg.com:80"
  type 'TCP'
end

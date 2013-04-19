# Cookbook Name:: copperegg
# Recipe:: reload.rb
#
# Copyright 2013 CopperEgg
#

include_recipe "copperegg::service"

service "revealcloud" do
  action :stop
end

script 'remove_conf' do
  interpreter "bash"
  cwd
  user "root"
  code <<-EOH   
    rm /etc/copperegg/copperegg.conf
  EOH
  action :run
end

include_recipe "copperegg::default" 



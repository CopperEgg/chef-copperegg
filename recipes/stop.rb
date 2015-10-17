#
# Cookbook Name:: copperegg
# Recipe:: stop
#
# Copyright 2013 IDERA
# License:: MIT License
#
if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  service "revealcloud" do
    action :stop
  end
elsif platform?('windows')
  service 'RevealCloud' do
    action :stop
  end
end

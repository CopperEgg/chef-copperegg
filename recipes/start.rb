#
# Cookbook Name:: copperegg
# Recipe:: start
#
# Copyright 2013 CopperEgg
# License:: MIT License
#

if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  service "revealcloud" do
    action :start
  end
elsif platform?('windows')
  service 'RevealCloud' do
    action :start
  end
end

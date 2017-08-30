# Cookbook Name:: uptime_cloud_monitor
# Recipe:: copperegg-handler
# Copyright 2013-2017 IDERA
# License:: MIT License

include_recipe 'chef_handler'

# When running on Chef versions below 10.10, we have to use the gem_package workaround to install our handler,
# as chef_gem was not introduced until 10.10.
# See http://www.opscode.com/blog/2009/06/01/cool-chef-tricks-install-and-use-rubygems-in-a-chef-run/
#

if(Gem::Version.new(Chef::VERSION) < Gem::Version.new('0.10.9'))
  r = gem_package 'chef-handler-uptime_cloud_monitor' do
    action :nothing
  end
  r.run_action(:install)
  Gem.clear_paths
else
  chef_gem 'chef-handler-uptime_cloud_monitor'
end
require 'chef/handler/uptime_cloud_monitor'

hostname = node['name']
if node.attribute?('ec2') && node['ec2'].attribute?('instance_id')
  hostname = hostname + ' (' + node['ec2']['instance_id'] + ')'
end

chef_handler 'Chef::Handler:uptime_cloud_monitor' do
  arguments ['apikey' => node['copperegg']['apikey'],
             'annotate_success' => node['copperegg']['annotate_chefrun_success'],
             'annotate_fail' => node['copperegg']['annotate_chefrun_fail'],
             'tags' =>  node['copperegg']['alltags'].join(','),
             'hostname' => hostname  ]
  source 'chef/handler/uptime_cloud_monitor'
  supports :report => true, :exception => true
  action :nothing
end.run_action(:enable)

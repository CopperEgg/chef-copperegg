#
# Cookbook Name:: copperegg
# Recipe:: copperegg-handler
#
# Copyright 2013 CopperEgg
# License:: MIT License
#
include_recipe 'chef_handler'

r = gem_package 'chef-handler-copperegg' do
  action :nothing
end
r.run_action(:install)

Gem.clear_paths

require 'chef/handler/copperegg'

hostname = node.name
if node.attribute?('ec2') && node.ec2.attribute?('instance_id')
  hostname = hostname + ' (' + node['ec2']['instance_id'] + ')'
end
      

chef_handler 'Chef::Handler::Copperegg' do
  arguments ['apikey' => node['copperegg']['apikey'], 
            'annotate_success' => node['copperegg']['annotate_chefrun_success'], 
            'annotate_fail' => node['copperegg']['annotate_chefrun_fail'], 
            'tags' =>  node['copperegg']['alltags'],
            'hostname' => hostname  ]
  source 'chef/handler/copperegg'
  supports :report => true, :exception => true
  action :nothing
end.run_action(:enable)


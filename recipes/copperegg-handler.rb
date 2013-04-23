#
# Cookbook Name:: copperegg
# Recipe:: copperegg-handler
#
# Copyright 2013 CopperEgg
#
# Redistribution Encouraged
#
include_recipe 'chef_handler'

cookbook_file "/tmp/chef-handler-copperegg.gem" do
  source "chef-handler-copperegg.gem"
  mode 00644
  action :nothing
end.run_action(:create_if_missing)

chef_gem 'chef-handler-copperegg.gem' do
  source("/tmp/chef-handler-copperegg.gem") 
  version "0.1.2"
  action :install
  only_if {File.exists?("/tmp/chef-handler-copperegg.gem")}
end

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


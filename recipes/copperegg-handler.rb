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
  version "> 0.0.6"
  action :install
  only_if {File.exists?("/tmp/chef-handler-copperegg.gem")}
end

require 'chef/handler/copperegg'

chef_handler 'Chef::Handler::Copperegg' do
  arguments [:api_key => node['copperegg']['api_key'] ]
  source 'chef/handler/copperegg'
  supports :report => true, :exception => true
  action :nothing
end.run_action(:enable)


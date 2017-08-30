# Cookbook Name:: uptime_cloud_monitor
# Recipe:: _windows-collector
# Copyright 2013-2017 IDERA
# License:: MIT License #

apikey = node['copperegg']['apikey']
copperegg_url = node['copperegg']['url']

@cuegg = CopperEgg::API.new(node['copperegg']['apikey'],'win_collector')

installer_url = @cuegg.get_installer_url()
if installer_url != nil && installer_url['installer'] != nil
  current_url = installer_url['installer']

  windows_package 'RevealCloudSetup.msi' do
    source current_url
    installer_type :msi
    action :install
    options "/qbr APIKEY=\"#{node['copperegg']['apikey']}\" TAGS=\"#{tag_list}\" LABEL=\"#{node['copperegg']['label']}\""
  end

  service 'RevealCloud' do
    action :enable
  end
  service 'RevealCloud' do
    action :start
  end
end

# Cookbook Name:: copperegg
# Recipe:: _linux-collector
# Copyright 2013-2017 IDERA
# License:: MIT License


apikey = node['copperegg']['apikey']
copperegg_url = node['copperegg']['url']

ruby_block 'latest_collector_version' do
  block do
   @cuegg = CopperEgg::API.new(node['copperegg']['apikey'],'nix_collector')
    unless @cuegg.collector_state_latest(node['copperegg']['update_latest'])
      @cuegg.uninstall_collector
    end
  end
  action :run
  only_if { !node['copperegg']['uninstall_collector'] && node['copperegg']['update_latest'] }
end

script 'revealcloud_install' do
  interpreter 'bash'
  cwd
  user 'root'
  code <<-EOH
      curl https://#{apikey}:U@#{copperegg_url}/chef.sh  > /tmp/revealcloud_installer.sh
      chmod +x /tmp/revealcloud_installer.sh
      export RC_TAG="#{node['copperegg']['alltags'].join(',')}"
      export RC_LABEL="#{node['copperegg']['label']}"
      export RC_PROXY="#{node['copperegg']['proxy']}"
      export RC_OOM_PROTECT="#{node['copperegg']['oom_protect']}"
      /tmp/revealcloud_installer.sh
  EOH
  action :run
  not_if { File.exists? node['copperegg']['config_file'] || node['copperegg']['uninstall_collector'] }
end


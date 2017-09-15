# Cookbook Name:: uptime_cloud_monitor
# Recipe:: _install
# Copyright 2013-2017 IDERA
# License:: MIT License


apikey = node['copperegg']['apikey']
copperegg_url = node['copperegg']['url']
is_windows = (node['platform_family'] == 'windows')

directory node['copperegg']['config_dir'] do
  if is_windows
    owner 'Administrators'
    rights :full_control, 'Administrators'
    inherits false
  else
    owner 'root'
    group 'root'
    mode 0755
  end
  action :create
  not_if { node['copperegg']['uninstall_collector'] }
end

agent_config_file = node['copperegg']['config_file']
template agent_config_file do
  if is_windows
    owner 'Administrators'
    rights :full_control, 'Administrators'
    inherits false
  else
    owner 'root'
    group 'root'
    mode 0664
    action :create
  end
  source 'copperegg.conf.erb'
  variables(
    :apikey => apikey,
    :url => copperegg_url
  )
  not_if { node['copperegg']['uninstall_collector'] }
end


if is_windows
  service 'RevealCloud' do
    action :enable
    only_if { File.exists?(agent_config_file) }
  end

  service 'RevealCloud' do
    action :start
    only_if { File.exists?(agent_config_file) }
  end

else
  service 'revealcloud' do
    supports :restart => true, :status => true, :start => true, :stop => true
    action [:start]
    only_if { File.exists?(agent_config_file) }
  end

end

unless is_windows
  if node['copperegg']['create_sshprobe'] && node.attribute?('ec2') && node['ec2'].attribute?('public_hostname')
    hn = "CheckPort22_#{node['hostname']}"
    pd = "#{node['ec2']['public_hostname']}:22"
    tag_array = node['copperegg']['alltags']

    uptime_cloud_monitor_probe hn do
      probe_desc hn
      probe_dest pd
      type 'TCP'
      tags tag_array
      action :update
    end
  end
end


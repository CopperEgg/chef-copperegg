# Cookbook Name:: uptime_cloud_monitor
# Recipe:: _uninstall
# Copyright 2013-2017 IDERA
# License:: MIT License


is_windows = (node['platform_family'] == 'windows')
apikey = node['copperegg']['apikey']
copperegg_url = node['copperegg']['url']

unless is_windows
  service 'revealcloud' do
    action :stop
    notifies :run, "script[revealcloud_uninstall]", :immediately
  end

  script 'revealcloud_uninstall' do
    interpreter 'bash'
    cwd
    user 'root'
    code <<-EOH
        curl https://#{apikey}@#{copperegg_url}/rc_rm.sh  > /tmp/revealcloud_uninstaller.sh
        chmod +x /tmp/revealcloud_uninstaller.sh
        rm -rf /etc/copperegg/
        /tmp/revealcloud_uninstaller.sh
    EOH
    action :nothing
    notifies :create, "ruby_block[hide_system]", :delayed
  end

else
  service 'RevealCloud' do
    action :stop
  end
  Chef::Log.info "Removing Windows package"
  windows_package 'RevealCloudSetup.msi' do
    action :remove
    notifies :create, "ruby_block[hide_system]", :delayed
  end
end

# Hide the system (CopperEgg api call)
ruby_block 'hide_system' do
  block do
    @cuegg = CopperEgg::API.new(apikey, 'system')
    myhash = @cuegg.get_myuuid(node['hostname'])
    if myhash
      if node['copperegg']['remove_on_uninstall'] == true
        rslt = @cuegg.remove_system(myhash['uuid'])
      else
        rslt = @cuegg.hide_system(myhash['uuid'])
      end
    else
      Chef::Log.info "UUID not found for hostname #{node['hostname']}"
    end
   action :nothing
  end
end

# remove the automatic ssh probe, if enabled
unless is_windows
  if node['copperegg']['create_sshprobe'] && node.attribute?('ec2') && node['ec2'].attribute?('public_hostname')
    hn = "CheckPort22_#{node['hostname']}"
    pd = "#{node['ec2']['public_hostname']}:22"

    uptime_cloud_monitor_probe hn do
      probe_desc hn
      probe_dest pd
      type 'TCP'
      action :delete
    end
  end
end

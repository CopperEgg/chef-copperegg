#
# Cookbook Name:: copperegg
# Recipe:: uninstall.rb
#
# Copyright 2013 CopperEgg
#
#
if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  service 'revealcloud' do
    action :stop
    notifies :run, "script[revealcloud_uninstall]", :immediately
  end

  script 'revealcloud_uninstall' do
    interpreter 'bash'
    cwd
    user 'root'
    code <<-EOH
        curl http://#{node['copperegg']['apikey']}@api.copperegg.com/rc_rm.sh  > /tmp/revealcloud_uninstaller.sh
        chmod +x /tmp/revealcloud_uninstaller.sh
        rm -rf /etc/copperegg/
        /tmp/revealcloud_uninstaller.sh
    EOH
    action :nothing
    notifies :create, "ruby_block[hide_system]", :delayed
  end

elsif platform?('windows')
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
    @cuegg = CopperEgg::API.new(node['copperegg']['apikey'],'system')
    myhash = Hash.new  
    myhash = @cuegg.get_myuuid(node['hostname'])
    if myhash != nil
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
if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  if node['copperegg']['create_sshprobe'] && node.attribute?('ec2') && node.attribute.ec2.attribute?('public_hostname')
    hn = "CheckPort22_#{node['hostname']}"
    pd = "#{node['ec2']['public_hostname']}:22"

    copperegg_probe hn do
      provider "copperegg_probe"
      action :delete
      probe_desc hn
      probe_dest pd
      type 'TCP'
    end
  end
end


# Remove this role from the run_list after a the new server is built.
ruby_block 'remove uninstall recipe' do
  block {node.run_list.remove('recipe[copperegg::uninstall]')}
end

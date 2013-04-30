#
# Cookbook Name:: copperegg
# Recipe:: default
#
# Copyright 2013 CopperEgg
# License:: MIT License
#

tags = []
cetags = ''
tmpfqdn = ''
tag_list = ''
current_url = ''
node.default['copperegg']['must_restart'] = false
node.default['copperegg']['template_updated'] = false

if  node.copperegg.attribute?('tags') 
  cetags = node.copperegg.tags
end

# If node.copperegg.tags_override exists regardless of value, then do _not_
# include the chef_environment and chef roles in the tag list
unless node.copperegg.attribute?('tags_override')

  # Take the tags specified at the node and add to them the chef_environment and the roles

  # Add the chef environment to the list
  if  node.copperegg.include_env_astag 
    tags.push(node.chef_environment)
  end

  # Add any chef roles to the list
  if node.copperegg.include_roles_astags 
    node.roles.each do |role|
      tags.push(role)
    end
  end

  if node.copperegg.include_chef_tags 
    # Add any chef tags to the list
    node.tags.each do |tag|
      tags.push(tag)
    end
  end
end

# Create a comma seperated list of tags.
tag_list = tags.uniq.join(',')
tag_list = tag_list + ',' + cetags
node.normal['copperegg']['alltags'] = tag_list

if node.copperegg.attribute?('use_fqdn') 
  if node['copperegg']['use_fqdn']
    Chef::Log.warn('Setting UUID to FQDN:\n')
    tmpfqdn = node['fqdn']
    node.normal['copperegg']['node_fqdn'] = "#{node.fqdn}"
  end
end

if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
 
  directory '/etc/copperegg' do
    owner 'root'
    group 'root'
    mode 0764 
    action :create
  end

  ruby_block 'template_update' do
    block do
      Chef::Log.warn('Template update!')
      node.default['copperegg']['template_updated'] = true  
    end
    action  :nothing
  end

  template '/etc/copperegg/copperegg.conf' do
    owner 'root'
    group 'root'
    source 'copperegg.conf.erb'
    mode 0664
    action :create
    notifies :create, "ruby_block[template_update]", :immediately 
  end

 ruby_block 'check_current_state' do
    block do
      @cuegg = CopperEgg::API.new(node['copperegg']['apikey'],'nix_collector')
      rslt = @cuegg.get_collector_state(node.default['copperegg']['template_updated'])
      node.default['copperegg']['must_restart'] = rslt
    end
  end

  script 'revealcloud_install' do
    interpreter 'bash'
    cwd
    user 'root'
    code <<-EOH
        curl http://#{node['copperegg']['apikey']}:U@api.copperegg.com/chef.sh  > /tmp/revealcloud_installer.sh
        chmod +x /tmp/revealcloud_installer.sh
        export RC_TAG="#{tag_list}"
        export RC_LABEL="#{node[:copperegg][:label] || ''}"
        export RC_PROXY="#{node[:copperegg][:proxy] || ''}"
        export RC_OOM_PROTECT="#{node[:copperegg][:oom_protect] || ''}"
        export RC_UUID="#{tmpfqdn}"
        /tmp/revealcloud_installer.sh
    EOH
    action :run
    only_if {node.default['copperegg']['must_restart'] == true}
  end

  service 'revealcloud' do
    supports :start => true, :stop => true, :restart => true
    action :start
  end

elsif platform?('windows')
  
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
end

if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  if node['copperegg']['create_sshprobe'] && node.attribute?('ec2') && node.attribute.ec2.attribute?('public_hostname')
    hn = "CheckPort22_#{node['hostname']}"
    pd = "#{node['ec2']['public_hostname']}:22"
    tag_array = tag_list.split(',')

    copperegg_probe hn do
      provider "copperegg_probe"
      action :update
      probe_desc hn
      probe_dest pd
      type 'TCP'
      tags tag_array
    end
  end
end


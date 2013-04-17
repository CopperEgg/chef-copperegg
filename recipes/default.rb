#
# Cookbook Name:: copperegg
# Recipe:: default
#
# Copyright 2013 CopperEgg
#
# Redistribution Encouraged
#

tags = []
cetags = ''
tmpfqdn = ''
tag_list = ''


if platform?("redhat", "centos", "fedora", "ubuntu", "debian", "amazon")

  #include_recipe "copperegg::service"     # which temporarily refers to revealcloud service

  service 'revealcloud' do
    supports :start => true, :stop => true, :restart => true
    action :nothing
  end

  directory "/etc/copperegg" do
    owner "root"
    group "root"
    mode 0764
  end
 
  execute 'remove_conf' do
    command "rm /etc/copperegg/copperegg.conf"
    action :nothing
  end

  ruby_block 'reload_attrs' do
    block do
      node.from_file(run_context.resolve_attribute("copperegg", "default"))
    end
    action :nothing
  end


  script "revealcloud_install" do
    interpreter "bash"
    cwd
    user "root"
    code <<-EOH
        curl http://#{node[:copperegg][:apikey]}@api.copperegg.com/rc.sh  > /tmp/revealcloud_installer.sh 
        chmod +x /tmp/revealcloud_installer.sh
        source /etc/copperegg/profile
        /tmp/revealcloud_installer.sh
    EOH
    action :nothing
  end

  ruby_block "update tags" do
    block do
      if ( node.copperegg.attribute?('tags') )
        cetags = node.copperegg.tags
      end
    
      # If node.copperegg.tags_override exists regardless of value, then do _not_
      # include the chef_environment and chef roles in the tag list
      if( !node.copperegg.attribute?("tags_override"))
    
        # Take the tags specified at the node and add to them the chef_environment and the roles

        # Add the chef environment to the list
        if ( node.copperegg.include_env_astag )
          tags.push(node.chef_environment)
        end

        # Add any chef roles to the list
        if ( node.copperegg.include_roles_astags )
          node.roles.each do |role|
            tags.push(role)
          end
        end
    
        if ( node.copperegg.include_chef_tags )
          # Add any chef tags to the list
          node.tags.each do |tag|
            tags.push(tag)
          end
        end
      end

      if (node.copperegg.attribute?('use_fqdn') )
        if (node.copperegg.use_fqdn == true)
          Chef::Log.warn("Setting UUID to FQDN:\n")
          tmpfqdn = "#{node.fqdn}"  
          node.set['copperegg']['node_fqdn'] = "#{node.fqdn}"  
        end
      end

      # Create a comma seperated list of tags.
      tag_list = tags.uniq.join(",")
      tag_list = tag_list + ',' + cetags
      node.set['copperegg']['alltags'] = tag_list

      ::File.open("/etc/copperegg/profile", "w") do |f|
          f.puts <<-EOH
export RC_TAG="#{tag_list}"
export RC_LABEL="#{node[:copperegg][:label] || ''}"
export RC_PROXY="#{node[:copperegg][:proxy] || ''}"
export RC_OOM_PROTECT="#{node[:copperegg][:oom_protect] || ''}"
export RC_UUID="#{tmpfqdn}"
EOH
      end
    end
    not_if { File.exist?("/usr/local/revealcloud/run/revealcloud.pid") }
  end

  template "/etc/copperegg/copperegg.conf" do
    owner "root"
    group "root"
    source 'copperegg.conf.erb'
    mode 0664
    action :create_if_missing
    variables(
      :api_key => node.copperegg.apikey,
      :tags => node.copperegg.tags,
      :label => node.copperegg.label,
      :oom_protect => node.copperegg.oom_protect,
      :use_fqdn => node.copperegg.use_fqdn,
      :alltags => node.copperegg.alltags,
      :include_chef_tags => node.copperegg.include_chef_tags,
      :include_roles_astags => node.copperegg.include_roles_astags,
      :include_env_astag => node.copperegg.include_env_astag,
      :node_fqdn => node.copperegg.node_fqdn
    )
    notifies :create, resources(:ruby_block => "reload_attrs"), :immediately
    notifies :run, resources(:script => "revealcloud_install"), :delayed
    notifies :start, resources(:service => "revealcloud"), :delayed
  end

  execute 'copperegg_reload' do
    action :nothing
    notifies :stop, "service[revealcloud]", :immediately
    notifies :run, "execute[remove_conf]", :immediately
    notifies :run, resources(:ruby_block => "update tags"), :immediately
    notifies :create, resources(:template => "/etc/copperegg/copperegg.conf"), :immediately
  end

end   # end of    if platform?("redhat", "centos", "fedora", "ubuntu", "debian")

if platform?('windows')
  windows_package "RevealCloudSetup.msi" do
    source "http://s3.amazonaws.com/cuegg_collectors/revealcloud/3.0.41.0/windows/RevealCloudSetup.msi"
    installer_type :msi
    action :install
    options "/qbr APIKEY=\"#{node[:copperegg][:apikey]}\" TAGS=\"" + tag_list + "\" LABEL=\"my winserver\""
  end

end  










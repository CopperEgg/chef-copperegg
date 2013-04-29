# Cookbook Name:: copperegg
# Recipe:: reload.rb
#
# Copyright 2013 CopperEgg
# License:: MIT License
#
#   The reload recipe should be inserted into your run list immediately before your copperegg recipe.
#  After the reload recipe runs, it will remove itself from your run list.

if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')

  # Remove this recipe from the run_list after the reload
  ruby_block 'remove reload-linux' do
    block {node.run_list.remove('recipe[copperegg::reload]')}
    action :nothing
  end

  ruby_block 'nix_uninstall' do
    block do
      @cuegg = CopperEgg::API.new(node['copperegg']['apikey'],'nix_collector')
      rslt = @cuegg.uninstall_collector()
    end
    action :nothing
    notifies :create, "ruby_block[remove reload-linux]", :immediately 
  end

  service 'revealcloud' do
    action :stop
    notifies :create, "ruby_block[nix_uninstall]", :immediately
  end

elsif platform?('windows')

 # Remove this recipe from the run_list after the reload
  ruby_block 'remove reload-win' do
    block {node.run_list.remove('recipe[copperegg::reload]')}
    action :nothing
  end

  Chef::Log.info "Removing Windows package"
  windows_package 'RevealCloudSetup.msi' do
    action :nothing
  end

  service 'RevealCloud' do
    action :stop
    notifies :remove, "windows_package[RevealCloudSetup.msi]", :immediately
    notifies :create, "ruby_block[remove reload-win]", :immediately
  end
end
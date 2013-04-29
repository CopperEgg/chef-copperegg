#
# Cookbook Name:: copperegg
# Recipe:: restart
#
# Copyright 2013 CopperEgg
# License:: MIT License
#

if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  service "revealcloud" do
    action :restart
  end
elsif platform?('windows')
  service 'RevealCloud' do
    action :restart
  end
end

# Remove this recipe from the run_list after the restart
ruby_block 'remove restart' do
  block {node.run_list.remove('recipe[copperegg::restart]')}
end
if platform?('redhat', 'centos', 'fedora', 'ubuntu', 'debian', 'amazon')
  if File.exists?('/etc/init.d/revealcloud')

    service 'revealcoud' do
      action :stop
    end

    script 'revealcloud_uninstall' do
      interpreter 'bash'
      cwd
      user 'root'
      code <<-EOH
          curl http://#{node['copperegg']['apikey']}@api.copperegg.com/rc_rm.sh  > /tmp/revealcloud_uninstaller.sh
          chmod +x /tmp/revealcloud_uninstaller.sh
          source /etc/copperegg/profile
          rm -rf /etc/copperegg/
          /tmp/revealcloud_uninstaller.sh
      EOH
      action :run
    end
  end
end

# Remove this role from the run_list after a the new server is built.
ruby_block 'remove uninstall recipe' do
  block {node.run_list.remove('recipe[chef-copperegg::uninstall]')}
end

if platform?("redhat", "centos", "fedora", "ubuntu", "debian", "amazon")
  if File.exists?("/etc/init.d/revealcloud")
#    include_recipe "copperegg::service"

    service "revealcoud" do
      action :stop
    end

    script "revealcloud_uninstall" do
      interpreter "bash"
      cwd
      user "root"
      code <<-EOH
          curl http://#{node[:copperegg][:apikey]}@api.copperegg.com/rc_rm.sh  > /tmp/revealcloud_uninstaller.sh 
          chmod +x /tmp/revealcloud_uninstaller.sh
          source /etc/copperegg/profile
          rm -rf /etc/copperegg/
          /tmp/revealcloud_uninstaller.sh
      EOH
      action :run
    end
  end
end
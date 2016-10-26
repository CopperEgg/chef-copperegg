
default['copperegg']['must_restart'] = false
default['copperegg']['update_latest'] = true

if node['platform_family'] == 'windows'
  default['copperegg']['config_dir'] = "#{ENV['ProgramData']}/Copperegg"
else
  default['copperegg']['config_dir'] = '/etc/copperegg'
end

default['copperegg']['config_file'] = ::File.join(default['copperegg']['config_dir'], 'copperegg.conf')

# Remove system on uninstall
default['copperegg']['uninstall_collector'] = false
default['copperegg']['remove_on_uninstall'] = false


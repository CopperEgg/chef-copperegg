# service.rb resides in the copperegg cookbook
# for now, the actual name of the running service is revealcloud

service 'revealcloud' do
  supports :start => true, :stop => true, :restart => true
  action :nothing
end

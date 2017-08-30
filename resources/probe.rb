# Cookbook Name:: uptime_cloud_monitor
# Resource:: probe
# Copyright 2012-2017 Uptime Cloud Monitor Corporation
# License:: MIT License

# Note that update will either update an existing probe, or create a new probe.
# For a complete understanding of these settings see our API documentation at
# http://dev.copperegg.com/revealuptime/probes.html
property :probe_desc, String, name_property: true, required: true
# url, IP, or IP:port
property :probe_dest, String, required: true
# 'GET', 'POST', 'TCP' or 'ICMP'.
property :type, String, required: true, default: 'GET'
# used internally
property :probe_id, [NilClass,String], default: nil
#:default => 60, :equal_to => [15, 60, 300]
property :frequency, [NilClass,Integer]
#:default => 10000
property :timeout, [NilClass,Integer]
#:default => 'enabled'
property :state, [NilClass,Array]
property :stations, [NilClass,Array], default: ['dal','nrk','fre','atl']
#:default => []
property :tags, [NilClass,Array]
property :probe_data, [NilClass,String]
property :checkcontents, [NilClass,String]
property :contentmatch, [NilClass,String]
property :headers, [NilClass,Hash]
property :exists, [TrueClass, FalseClass], desired_state: false   # set when the resource has already been created
property :cuegg_probe

load_current_value do |desired|
  cuegg_probe CopperEgg::API.new(node['copperegg']['apikey'],'probe')

  probe_desc desired.probe_desc
  probe_dest desired.probe_dest
  type desired.type

  phash = cuegg_probe.get_probe_byname(desired.probe_desc,desired.probe_dest,desired.type)

  if phash != nil
    Chef::Log.info "Probe found #{desired.probe_desc}"
    probe_id cuegg_probe.get_probeid(phash)
    exists true
  end
end

action :update do
  if current_resource.exists
    converge_by("Update #{ new_resource }") do
      begin
        Chef::Log.info "Updating probe #{new_resource.probe_desc}"
        params = {'frequency' => new_resource.frequency,
                  'timeout' => new_resource.timeout,
                  'state ' => new_resource.state,
                  'stations' => new_resource.stations,
                  'tags' => new_resource.tags,
                  'probe_data' => new_resource.probe_data,
                  'checkcontents' => new_resource.checkcontents,
                  'contentmatch' => new_resource.contentmatch,
                  'headers' => new_resource.headers }
        cuegg_probe.update_probe(current_resource.probe_id, params)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    converge_by("Create #{ new_resource }") do
      begin
        Chef::Log.info "Creating probe #{new_resource.probe_desc}"
        params = {'probe_desc' => new_resource.probe_desc,
                  'probe_dest' => new_resource.probe_dest,
                  'type' => new_resource.type,
                  'frequency' => new_resource.frequency,
                  'timeout' => new_resource.timeout,
                  'state ' => new_resource.state,
                  'stations' => new_resource.stations,
                  'tags' => new_resource.tags,
                  'probe_data' => new_resource.probe_data,
                  'checkcontents' => new_resource.checkcontents,
                  'contentmatch' => new_resource.contentmatch,
                  'headers' => new_resource.headers }
        probehash = cuegg_probe.create_probe(new_resource.probe_desc, params )
        Chef::Log.info "probehash returned #{probehash.inspect}"
        if probehash != nil
          probe_id = cuegg_probe.get_probeid(probehash)
          Chef::Log.info "probe_id is #{probe_id}"
          if probe_id
            parray = node['copperegg']['myprobes']
            if parray && parray.include?(probe_id) == false
              Chef::Log.info "Adding probe_id #{probe_id} to array"
              parray << probe_id
              node.normal['copperegg']['myprobes'] = parray
            end
          end
        end
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  end
end

action :delete do
  if current_resource.exists
    converge_by("Delete #{ new_resource }") do
      begin
        Chef::Log.info "Removing probe #{new_resource.probe_desc}"
        cuegg_probe.delete_probe(current_resource.probe_id)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    Chef::Log.info "#{ current_resource } doesn't exist - can't delete."
  end
end

action :enable do
  if current_resource.exists
    converge_by("Enable #{ new_resource }") do
      begin
        params = {"state" => "enabled"}
        cuegg_probe.update_probe(current_resource.probe_id, params)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    Chef::Log.info "#{ current_resource } doesn't exist - can't enable."
  end
end

action :disable do
  if current_resource.exists
    converge_by("Disable #{ new_resource }") do
      begin
        params = {"state" => "disabled"}
        cuegg_probe.update_probe(current_resource.probe_id, params)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    Chef::Log.info "#{ current_resource } doesn't exist - can't disable."
  end
end

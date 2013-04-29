#
# Cookbook Name:: copperegg
# Provider:: probe
#
# Copyright 2012, 2013 CopperEgg Corporation
# License:: MIT License
#

# Support whyrun
def whyrun_supported?
  true
end

def load_current_resource
  @cuegg = CopperEgg::API.new(node.copperegg.apikey,'probe')

  @current_resource = Chef::Resource::CoppereggProbe.new(@new_resource.probe_desc)
  @current_resource.probe_desc(@new_resource.probe_desc)
  @current_resource.probe_dest(@new_resource.probe_dest)
  @current_resource.type(@new_resource.type)
  @phash = @cuegg.get_probe_byname(@new_resource.probe_desc,@new_resource.probe_dest,@new_resource.type)

  if @phash != nil
    Chef::Log.info "Probe found #{@new_resource.probe_desc}"
    @current_resource.probe_id(@cuegg.get_probeid(@phash))
    @current_resource.exists = true
  end
end

action :update do
  if @current_resource.exists
    converge_by("Update #{ @new_resource }") do
      begin
        Chef::Log.info "Updating probe #{new_resource.probe_desc}"
        params = {'frequency' => @new_resource.frequency,
                  'timeout' => @new_resource.timeout,
                  'state ' => @new_resource.state,
                  'stations' => @new_resource.stations,
                  'tags' => @new_resource.tags,
                  'probe_data' => @new_resource.probe_data,
                  'checkcontents' => @new_resource.checkcontents,
                  'contentmatch' => @new_resource.contentmatch   } 
        @cuegg.update_probe(@current_resource.probe_id, params)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    converge_by("Create #{ @new_resource }") do
      begin
        Chef::Log.info "Creating probe #{@new_resource.probe_desc}"
        params = {'probe_desc' => @new_resource.probe_desc,
                  'probe_dest' => @new_resource.probe_dest,
                  'type' => @new_resource.type,
                  'frequency' => @new_resource.frequency,
                  'timeout' => @new_resource.timeout,
                  'state ' => @new_resource.state,
                  'stations' => @new_resource.stations,
                  'tags' => @new_resource.tags,
                  'probe_data' => @new_resource.probe_data,
                  'checkcontents' => @new_resource.checkcontents,
                  'contentmatch' => @new_resource.contentmatch   } 
        probehash = @cuegg.create_probe(@new_resource.probe_desc, params )
        Chef::Log.info "probehash returned #{probehash.inspect}"
        if probehash != nil
          probe_id = @cuegg.get_probeid(probehash)
          Chef::Log.info "probe_id is #{probe_id}"
          if probe_id
            parray = node['copperegg']['myprobes']
            if parray.include?(probe_id) == false
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
  if @current_resource.exists
    converge_by("Delete #{ @new_resource }") do
      begin
        Chef::Log.info "Removing probe #{new_resource.probe_desc}"
        @cuegg.delete_probe(@current_resource.probe_id)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
  end
end

action :enable do
  if @current_resource.exists
    converge_by("Enable #{ @new_resource }") do
      begin
        params = {"state" => "enabled"}
        @cuegg.update_probe(@current_resource.probe_id, params)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't enable."
  end
end

action :disable do
  if @current_resource.exists
    converge_by("Disable #{ @new_resource }") do
      begin
        params = {"state" => "disabled"}
        @cuegg.update_probe(@current_resource.probe_id, params)
      rescue => error
        Chef::Log.warn(error.to_s)
      end
    end
  else
    Chef::Log.info "#{ @current_resource } doesn't exist - can't disable."
  end
end











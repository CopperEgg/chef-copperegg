# Cookbook Name:: Uptime Cloud Monitor
# Library:: copperegg_lib
# Copyright 2012-2017 IDERA
# License:: MIT License


module CopperEgg
  class API
    def initialize(apikey, resource_type)

      @apikey = apikey
      case resource_type
      when 'probe'
        @api_url = 'https://api.copperegg.com/v2/revealuptime/'
      when 'system'
        @api_url = 'https://api.copperegg.com/v2/revealcloud/'
      when 'handler'
        @api_url = 'https://api.copperegg.com/v2/annotations.json'
      when 'win_collector'
        @api_url = 'https://app.copperegg.com/api/2011-04-26/site/windowsinstaller.json'
      when 'nix_collector'
        @api_url = ''
      else
        raise 'Uptime Cloud Monitor::API invalid resource_type : #{resource_type}'
        return nil
      end
      @resource_type = resource_type
      @ignore_result = false
    end

    def valid_json?(json)
      begin
        JSON.parse(json)
      rescue Exception => e
        return false
      end
    end

    def uninstall_collector()
      Chef::Log.warn 'Removing Uptime Cloud Monitor collector'
      `curl -sk https://#{@apikey}:U@api.copperegg.com/rc_rm.sh  > /tmp/revealcloud_uninstaller.sh`
      `chmod +x /tmp/revealcloud_uninstaller.sh`
      `/tmp/revealcloud_uninstaller.sh`
    end

    def collector_state_latest(updated)
      rundir = File.directory?('/usr/local/revealcloud')
      confdir = File.directory?('/etc/copperegg/')
      collver = ''

      return true unless rundir

      mycmd = '/usr/local/revealcloud/revealcloud -V 2>&1 | grep Version'
      collver = `#{mycmd}`
      collver = collver.split(' ')[1]
      collver.chomp!

      `curl -sk https://#{@apikey}:U@api.copperegg.com/chef.sh  > /tmp/chef.sh`
      installer_ver = `grep URL_LINUX_64 /tmp/chef.sh -m 1 | cut -d '/' -f5`
      installer_ver.chomp!

      Chef::Log.warn " Showing versions :#{installer_ver} :#{collver}- #{updated}"

      if (installer_ver.empty?)
        Chef::Log.warn 'Could not get installer version from the API...skipping uninstall'
        return true
      end

      if(installer_ver==collver)
        Chef::Log.warn 'Already on the latest version'
        return true
      end
      Chef::Log.warn 'Your Uptime Cloud Monitor Collector is outdated. Updating..'
      return false
    end

    def get_probelist()
      Chef::Log.info 'get_probelist'
      return api_request('get', 'probes.json')
    end

    def get_probe(probe_id)
      Chef::Log.info "get_probe with id #{probe_id}"
      return api_request('get', "probes/#{probe_id}.json")
    end

    def get_probe_byname(name, dest, type)
      allprobes = self.get_probelist()
      if (allprobes != nil) && (allprobes.length > 0)
        ind = allprobes.index{|x| x['probe_desc'] == name && x['probe_dest'] == dest && x['type'] == type}
        if ind != nil
          return allprobes[ind]
        end
      end
      return nil
    end

    def get_probeid(phash)
      phash['id']
    end

    def create_probe(name, params)
      Chef::Log.info 'Create_probe'
      body = params.keep_if{ |k,v| v != nil }
      return api_request('post', 'probes.json', body)
    end

    def update_probe(probe_id, params)
      Chef::Log.info 'Update_probe'
      body = params.keep_if{ |k,v| v != nil }
      return api_request('put',"probes/#{probe_id}.json",body)
    end

    def delete_probe(probe_id)
      Chef::Log.info 'Delete_probe'
      return api_request('delete',"probes/#{probe_id}.json")
    end

    def add_probetag(probe_id, tag)
      Chef::Log.info 'add_probetag'
    end

    def remove_probetag(probe_id, tag)
      Chef::Log.info 'remove_probetag'
    end

    def create_annotation(hostname,params)
      Chef::Log.info 'create_annotation'
      body = params.keep_if{ |k,v| v != nil }
      return api_request('post', '', body)
    end

    def get_installer_url()
      Chef::Log.info 'get_installer_url'
      return api_request('get', '')
    end

    # Hide system
    def hide_system(uuid)
      Chef::Log.info "hide_system with uuid #{uuid}"
      @ignore_result = true
      return api_request('post', "uuids/#{uuid}/hide.json")
    end

    # Remove system
    def remove_system(uuid)
      Chef::Log.info "remove_system with uuid #{uuid}"
      @ignore_result = true
      return api_request('delete', "uuids/#{uuid}.json")
    end

    # returns an array of system_hashes, or nil
    def get_systemlist()
      Chef::Log.info 'get_systemlist'
      return api_request('get', 'systems.json')
    end

    # returns a system hash, or nil
    def get_myuuid(hostname)
      Chef::Log.info "get_myuuid for hostname #{hostname}"
      system_list = self.get_systemlist()

      if (system_list != nil) && (system_list.length > 0)
        ind = system_list.index{|x| x['a']['n'] == hostname }
        if ind != nil
          return system_list[ind]
        end
      end
      return nil
    end

    private

    def api_request(http_method, resource, body=nil)
      attempts = 120
      exception_try_count = 0
      connect_try_count = 0
      if resource == ''
        uri = URI.parse(@api_url)
      else
        uri = URI.parse(@api_url + URI.escape(resource))
      end

      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request_uri = uri.request_uri
      request = case http_method
      when 'get'
        Net::HTTP::Get.new(request_uri)
      when 'post'
        Net::HTTP::Post.new(request_uri)
      when 'put'
        Net::HTTP::Put.new(request_uri)
      when 'delete'
        Net::HTTP::Delete.new(request_uri)
      end
      request.add_field('Content-Type', 'application/json')
      request.basic_auth(@apikey, 'U')
      request.body = body.to_json unless body.nil?

      while connect_try_count < attempts
        begin
          response = http.request(request)
          response_code = response.code.to_i

          case response_code
          when 200
            if @ignore_result == true
              return 200
            end
            response_body = valid_json?(response.body)
            if response_body
              return response_body
            else
              raise "Uptime Cloud Monitor::API invalid JSON response ... #{request}  #{request_uri}"
            end
          end
        rescue Exception => e
          exception_try_count += 1
          if exception_try_count > attempts
            raise "Uptime Cloud Monitor::API #{e} ... #{exception_try_count} retries: #{request}  #{request_uri}"
          else
            if $verbose == true
              puts "\nGet: exception: retrying\n"
            end
            sleep 0.5
          end
        retry
        end  # of begin rescue end
        connect_try_count += 1
        if $verbose == true
          puts "Retrying\n"
        end
        sleep 1.0
      end
#     need to fail here
      raise "Uptime Cloud Monitor::API ... exceeded #{connect_try_count} retries: #{request}  #{request_uri}"
    end
  end
end

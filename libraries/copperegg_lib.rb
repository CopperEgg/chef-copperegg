#
# Cookbook Name:: CopperEgg
# Library:: copperegg_lib
#
# Copyright 2012,2013 CopperEgg Corp
#
#
# resource_type can be :probe or :system
#
module CopperEgg
  class API
    def initialize(apikey, resource_type)
      @apikey = apikey
      case resource_type
      when 'probe'
        @api_url = "https://api.copperegg.com/v2/revealuptime/"
      when 'system'
        @api_url = "https://api.copperegg.com/v2/revealcloud/"
      when 'handler'
         @api_url = "https://api.copperegg.com/v2/annotations.json"
      else
        raise "CopperEgg::API invalid resource_type : #{resource_type}" 
        return nil
      end
      @resource_type = resource_type
    end

    def valid_json? json_
      begin
        JSON.parse(json_)
      rescue Exception => e
        return nil
      end
    end

    # returns an array of probe_hashes, or nil
    def get_probelist()
      Chef::Log.debug "get_probelist \n" 
      return api_request('get', 'probes.json')
    end

    def get_probe(probe_id)                     # retrieve a specific probe from CopperEgg
      Chef::Log.debug "get_probe \n"      
      return api_request('get', "probes/#{probe_id}.json")
    end

    def get_probe_byname(name, dest, type)
      allprobes = get_probelist()
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
      Chef::Log.debug "Create_probe \n"
      body = params.keep_if{ |k,v| v != nil }
      return api_request('post', 'probes.json', body)
    end

    def update_probe(probe_id, params)
      Chef::Log.debug "Update_probe \n"
      body = params.keep_if{ |k,v| v != nil }
      return api_request('put',"probes/#{probe_id}.json",body)
    end

    def delete_probe(probe_id)
      Chef::Log.debug "Delete_probe \n"
      return api_request('delete',"probes/#{probe_id}.json")
    end

    def add_probetag(probe_id, tag)
      Chef::Log.debug "add_probetag \n" 
    end

    def remove_probetag(probe_id, tag)
      Chef::Log.debug "remove_probetag \n" 
    end

    # returns an array of probe_hashes, or nil
    def get_systemlist()
      Chef::Log.debug "get_systemlist \n" 
      return api_request('get', 'systems.json')
    end

    def get_system(uuid)                     # retrieve a specific system from CopperEgg
      Chef::Log.debug "get_system \n"      
      return api_request('get', "systems/#{uuid}.json")
    end

    def add_systemtag(name, params)
      Chef::Log.debug "add_systemtag \n"
      body = {"probe_desc"=>params["probe_desc"],
              "probe_dest"=>params["probe_dest"],
              "type"=>params["type"],
              "frequency"=>params["frequency"],
              "timeout"=>params["timeout"],
              "state"=>params["state"],
              "stations"=>params["stations"],
              "tags"=>params["tags"],
              "probe_data"=>params["probe_data"],
              "checkcontents"=>params["checkcontents"],
              "contentmatch"=>params["contentmatch"]  }
      return api_request('post', 'probes.json',body)
    end

    def remove_systemtag(name, params)
      Chef::Log.debug "remove_systemtag \n"
    end


    private

    def api_request(http_method, resource, body=nil)
      attempts = 2
      connect_try_count = 0
      uri = URI.parse(@api_url + URI.escape(resource))
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request_uri = uri.request_uri
      request = case http_method
      when "get"
        Net::HTTP::Get.new(request_uri)
      when "post"
        Net::HTTP::Post.new(request_uri)
      when "put"
        Net::HTTP::Put.new(request_uri)
      when "delete"
        Net::HTTP::Delete.new(request_uri)
      end
      request.add_field("Content-Type", "application/json")
      request.basic_auth(@apikey, 'U')
      request.body = body.to_json unless body.nil?
      
      begin
        Timeout::timeout(10) do
          response = http.request(request)
          response_code = response.code.to_i
 
          case response_code

          when 200
            response_body = valid_json?(response.body)
            if response_body == nil
              raise "CopperEgg::API invalid JSON response ... #{request}  #{request_uri}" 
              return nil
            end
          else
            raise "CopperEgg::API http error #{response_code} ... #{request}  #{request_uri}" 
            return nil
          end
          return response_body
        end
      rescue Timeout::Error
        connect_try_count += 1
        if connect_try_count > attempts
          raise "CopperEgg::API timeout ... #{request}  #{request_uri}" 
          return nil
        end
        sleep 0.5
      retry
      end
    end

  end
end

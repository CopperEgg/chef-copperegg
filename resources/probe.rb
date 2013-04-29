#
# Cookbook Name:: copperegg
# Resource:: probe
#
# Copyright 2012, 2013 CopperEgg Corporation
# License:: MIT License
#

actions :update, :delete, :enable, :disable
default_action :update

# Note that update will either update an existing probe, or create a new probe.
# For a complete understanding of these settings see our API documentation at
# http://dev.copperegg.com/revealuptime/probes.html
attribute :probe_desc, :kind_of => String, :name_attribute => true, :required => true
# url, IP, or IP:port
attribute :probe_dest, :kind_of => String,  :required => true
# 'GET', 'POST', 'TCP' or 'ICMP'.
attribute :type, :kind_of => String, :required => true, :default => 'GET'
# used internally
attribute :probe_id, :kind_of => [NilClass,String], :default => nil
#:default => 60, :equal_to => [15, 60, 300]
attribute :frequency, :kind_of => [NilClass,Fixnum]
#:default => 10000
attribute :timeout, :kind_of => [NilClass,Fixnum]
#:default => 'enabled'
attribute :state, :kind_of => [NilClass,Array]
attribute :stations, :kind_of => [NilClass,Array], :default => ['dal','nrk','fre','atl']
#:default => []
attribute :tags, :kind_of => [NilClass,Array]
attribute :probe_data, :kind_of => [NilClass,String]
attribute :checkcontents, :kind_of => [NilClass,String]
attribute :contentmatch, :kind_of => [NilClass,String]

attr_accessor :exists   # set when the resource has already been created

def initialize(*args)
  super
  @action = :create
end





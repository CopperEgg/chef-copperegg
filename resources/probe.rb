#
# Cookbook Name:: copperegg
# Resource:: probe
#
# Copyright 2012, 2013 CopperEgg Corporation
#
#

actions :create, :update, :delete, :enable, :disable
default_action :create

attribute :probe_desc, :kind_of => String, :name_attribute => true, :required => true
attribute :probe_dest, :kind_of => String,  :required => true               # url, IP, or IP:port
attribute :type, :kind_of => String, :required => true, :default => 'GET'   # 'GET', 'POST', 'TCP' or 'ICMP'.
attribute :probe_id, :kind_of => [NilClass,String], :default => nil         # used internally
attribute :frequency, :kind_of => [NilClass,Fixnum]                         #:default => 60, :equal_to => [15, 60, 300]
attribute :timeout, :kind_of => [NilClass,Fixnum]                           #:default => 10000
attribute :state, :kind_of => [NilClass,Array]                              #:default => 'enabled'
attribute :stations, :kind_of => [NilClass,Array]                           #:default => ['dal','nrk','fre','atl']
attribute :tags, :kind_of => [NilClass,Array]                               #:default => []
attribute :probe_data, :kind_of => [NilClass,String]
attribute :checkcontents, :kind_of => [NilClass,String]
attribute :contentmatch, :kind_of => [NilClass,String]

attr_accessor :exists   # set when the resource has already been created

def initialize(*args)
  super
  @action = :create
end





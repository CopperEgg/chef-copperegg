# Cookbook Name:: uptime_cloud_monitor
# # Attributes :: default
# Copyright 2013-2017 IDERA
# License:: MIT License

# Your use api key, found on this page:
# https://app.copperegg.com/#settings/site
# REQUIRED.  Revealcloud will not work without this attribute.
default['copperegg']['apikey'] = 'YOUR_USER_APIKEY'

# Comma and/or space separated list of tags to apply.  Useful for grouping systems.
# Tags are managed here:  https://app.copperegg.com/#revealcloud/tags
# Any nonexistant tags specified here will be created.
# Note: Tags may not have spaces. A space between two words will cause
#   the words to be treated as two separate tags.
# Note: Any tags already applied to a server being monitored will remain.
#   Setting tags here will only add tags.
# Optional.  This field may be left blank.
# Example: "devserver"
# Example: "database,replica,production"
default['copperegg']['tags'] = ['test']
default['copperegg']['alltags'] = []

# Label to apply to this system.  Only one may be specified.
# WARNING: labels are used in place of hostname.
#   Use only if this recipe is deployed to a single server,
#   or you desire multiple servers to have the same label
#   in the Dashboard and Alerts.
#   If this is not your desire, you may want to use a tag instead.
# Note: Do not include spaces in your label.
# Note: Leaving blank will not remove a label that is already set on a monitored system.
# Optional.  This field may be left blank.
# Example: "MySQL_Master"
default['copperegg']['label'] = ''

# Proxy to use to connect to revealcloud api from monitored server.
# Most users should leave this blank unless they know they need it.
# Optional.  This field may be left blank.
# Example: myproxy.mycorp.com:8080
default['copperegg']['proxy'] = ''

# Flag for determining if the Linux Out Of Memory manager (OOM) should be allowed
# to kill the RevealCloud process.  Can be overridden at the node level.
# true  => OOM protection Enabled; can NOT be killed by OOM.  Agent will be started with -O.
# false => OOM protection disabled; CAN be killed by oom.  Default.  Recommended.
default['copperegg']['oom_protect'] = false

# Flag for using the fqdn as the uuid
# Can be overridden at the node level.
# true  => Agent will be started with -U node.fqdn
# false => Default.  Recommended. Uptime Cloud Monitor will create a uuid.
default['copperegg']['use_fqdn'] = false

# Tags on the chef node will become tags in the Uptime Cloud Monitor system.
default['copperegg']['include_node_tags'] = true

# The role or roles assigned to your node will will become Uptime Cloud Monitor tags
default['copperegg']['include_roles_astags'] = true

# The environment this node lives in will become a Uptime Cloud Monitor tag.
default['copperegg']['include_env_astag'] = true

# Send Uptime Cloud Monitor an annotation for each successful chef run
default['copperegg']['annotate_chefrun_success'] = false

# Send Uptime Cloud Monitor an annotation for each failed chef run
default['copperegg']['annotate_chefrun_fail'] = true

# Create an external SSH probe for this node.
default['copperegg']['create_sshprobe'] = false

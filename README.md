Chef Cookbook for Uptime Cloud Monitor services
===========
* Chef cookbook for the Uptime Cloud Monitor collector agent and website / port probes.
* Requires a Uptime Cloud Monitor account to use.  [Free trial available](https://app.copperegg.com/signup).

Requirements
============
Chef 10 and up.

The following cookbooks are direct dependencies because they're used for common "default" functionality.
* curl(for copperegg::default)

The following cookbooks are direct dependencies
* On RHEL family distros, `recipe[yum::epel]` might be required.
* On Ubuntu, recipe[apt::default] might be required to install curl.

Platform
========
* Any Linux 2.6+ OS, including: Ubuntu, Debian, Vyatta, RedHat Enterprise, CentOS, Fedora, Amazon, SuSE, openSuSE, Gentoo, and many derivatives.
* Windows

Attributes
==========
* `default[:copperegg][:apikey]` = Your API Key available from the [Uptime Cloud Monitor App Settings Page](https://app.copperegg.com/#settings/site).
* `default[:copperegg][:tags]` = A comma separated list of tags to apply.  Optional.  [Manage your tags](https://app.copperegg.com/#revealcloud/tags).
* `default[:copperegg][:label]` = Label to apply in place of hostname when displaying in the dashboard.  WARNING: If you want the same label applied to multiple systems, you may want to consider tags instead.  This is most useful if you intend a recipe for a single server.  Optional.
* `default[:copperegg][:oom_protect]` = Flag for determining if the Linux Out Of Memory manager (OOM) should be allowed to kill the RevealCloud process. Default false (allow OOM to kill the process). Optional.
* `default[:copperegg][:proxy]` = Proxy server required to talk to the revealcloud api servers, such as `myproxy.mycorp.com:8080`.  Optional.  Leave blank unless you know what you are doing.
* `default[:copperegg][:use_fqdn] = Flag for using the fqdn as the uuid. true  => Agent will be started with -U node.fqdn . Default false. Optional.
* `default[:copperegg][:include_chef_tags]` = Propagate Chef node tags to Uptime Cloud Monitor tags. Default true.
* `default[:copperegg][:include_roles_astags]` = Propagate Chef node Roles to Uptime Cloud Monitor tags. Default true.
* `default[:copperegg][:include_env_astag]` = Propagate the Chef environment to a Uptime Cloud Monitor tag. Default true.
* `default[:copperegg][:annotate_chefrun_success]` = Send Uptime Cloud Monitor an annotation for each successful chef run. Default false.
* `default[:copperegg][:annotate_chefrun_fail]` = Send Uptime Cloud Monitor an annotation for each failed chef run. Default true.


Usage
=====
1. Download the Uptime Cloud Monitor cookbook into your `chef-repo/cookbooks/copperegg` directory: (the cookbook directory name must be copperegg)
* `git clone https://github.com/CopperEgg/chef-copperegg.git ./copperegg`, or
*  manually download from the Opscode community site `http://community.opscode.com/cookbooks/copperegg`, or
* `knife cookbook site download copperegg`
2. Set your apikey as described in the `Attributes` section.
* edit `copperegg/attributes/default.rb` and change YOUR_USER_API_KEY to be correct.
* or override `node[:copperegg][:apikey]` within role or enviromnet.
3. Set any other optional attributes described above, as desired.
4. Upload the cookbook to your chef server or hosted chef:
* `knife cookbook upload -a -o copperegg`
5. Include `recipe[revealcloud]` in the run_list for all of your servers.
* `knife node run_list add NODES 'recipe[copperegg]'`
6. Run chef-client on your nodes in whatever manner suits you, such as `sudo chef-client` or a batch job.
7. View your systems within 10 seconds in the [RevealCloud App](https://app.copperegg.com/#revealcloud/overview)


Creating and managing website and port probes
=====
1. The Uptime Cloud Monitor Cookbook contains a LightWeight Resource Provider (LWRP) for simplifying the automation of Uptime Cloud Monitor probes.
2. To create a copperegg probe, you need to include something similar to the following example:

```ruby
  copperegg_probe "ChefProbe2" do
    provider "copperegg_probe"
    action :update                        # update will create or update
    probe_desc 'ChefProbe2'               # the 'name' of the probe
    probe_dest "http://yoursite.com"      # the URL to test
    type 'GET'                            # the test type; in this case, an HTTP GET request
    stations ['dal','nrk']                # override the defaults and specify testing from Dallas and Fremont
    tags ["production",'load_balancer']   # The tags to apply to this probe
  end
```

3. You can find descriptions of all required and optional fields in copperegg/resources/probe.rb.
4. Refer to the Probe section of the Uptime Cloud Monitor API for further details:  [Uptime Cloud Monitor Probe API](http://dev.copperegg.com/revealuptime/probes.html)


Creating Annotations in the Uptime Cloud Monitor UI for chef run events.
=====
The Uptime Cloud Monitor Cookbook includes integration with the Chef Report and Exception
Handlers. To enable this functionality choose one of the following:
* Include the recipe copperegg-handler.rb in your run_list, or
* Include the recipe copperegg-handler in your application cookbook with
`include_recipe`.

That's it!

Note:
* By default, each chef run will create an annotation at copperegg only when the chef run fails.
* You can change this behavior by changing the [:copperegg][:annotate_chefrun_success] and [:copperegg][:annotate_chefrun_fail] attributes in the default attributes file or by overriding them in your application cookbook.


Links
=====
* [Uptime Cloud Monitor Homepage](https://www.idera.com/infrastructure-monitoring-as-a-service/)
* [Uptime Cloud Monitor Signup](https://app.copperegg.com/signup)
* [Uptime Cloud Monitor Login](https://app.copperegg.com/login)


License and Author
==================
Authors:: Ross Dickey, Scott Johnson
With Contributions from Drew Oliner (https://github.com/Drewzar)

(The MIT License)

Copyright © 2013,2014 [IDERA](http://idera.com)

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

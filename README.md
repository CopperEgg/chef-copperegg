Chef Cookbook for CopperEgg services
===========
* Chef cookbook for the CopperEgg collector agent and website / port probes.
* Requires a CopperEgg account to use.  [Free trial available](https://app.copperegg.com/signup).

Requirements
============
bash

Platform
========
* Any Linux 2.6+ OS, including: Ubuntu, Debian, Vyatta, RedHat Enterprise, CentOS, Fedora, Amazon, SuSE, openSuSE, Gentoo, and many derivatives.
* FreeBSD 7.x+
* Windows 

Attributes
==========
* `default[:copperegg][:apikey]` = Your API Key available from the [RevealCloud App Settings Page](https://app.copperegg.com/#settings/site).
* `default[:copperegg][:tags]` = A comma separated list of tags to apply.  Optional.  [Manage your tags](https://app.copperegg.com/#revealcloud/tags).
* `default[:copperegg][:label]` = Label to apply in place of hostname when displaying in the dashboard.  WARNING: If you want the same label applied to multiple systems, you may want to consider tags instead.  This is most useful if you intend a recipe for a single server.  Optional.
* `default[:copperegg][:proxy]` = Proxy server required to talk to the revealcloud api servers, such as `myproxy.mycorp.com:8080`.  Optional.  Leave blank unless you know what you are doing.

Usage
=====
1. Download into your chef-repo, either manually from the community chef webpage or:
* `knife cookbook site download revealcloud`
2. Set your apikey as described in the `Attributes` section.
* edit `revealcloud/attributes/default.rb` and change YOUR_USER_API_KEY to be correct.
3. Set any other optional attributes described above, as desired.
4. Upload the cookbook to your chef server or hosted chef:
* `knife cookbook upload -a -o revealcloud`
5. Include `recipe[revealcloud]` in the run_list for all of your servers.
* `knife node run_list add NODES 'recipe[revealcloud]'`
6. Run chef-client on your nodes in whatever manner suits you, such as `sudo chef-client` or a batch job.
7. View your systems within 10 seconds in the [RevealCloud App](https://app.copperegg.com/#revealcloud/overview)


Creating and managing website and port probes
=====




Links
=====
* [CopperEgg Homepage](http://www.copperegg.com)
* [RevealCloud Signup](https://app.copperegg.com/signup)
* [RevealCloud Login](https://app.copperegg.com/login)

License and Author
==================
Author:: Ross Dickey

Copyright 2012, CopperEgg, Inc.

No License.  Redistribution encouraged.


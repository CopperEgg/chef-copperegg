name             "copperegg"
maintainer       "CopperEgg, Inc."
maintainer_email "support@copperegg.com"
license          "MIT"
description      "Installs/Configures CopperEgg services"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.1"

recipe "copperegg::default", "Installs CopperEgg collector binary"

# Uncomment to include support for Windows
#depends "windows"

supports 'linux', ">= 2.6.9"
supports 'ubuntu', ">= 8.04"
supports 'debian', ">= 5.0"
supports 'vyatta'
supports 'redhat', ">= 5.0"
supports 'centos', ">= 5.0"
supports 'fedora', ">= 14.0"
supports 'amazon', ">= 2011.02.1"
supports 'suse', ">= 11.0"
supports 'opensuse', ">= 11.0"
supports 'gentoo', ">= 1.12"
supports 'windows'

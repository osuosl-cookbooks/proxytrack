name             'proxytrack'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16'
issues_url       'https://github.com/osuosl-cookbooks/proxytrack/issues'
source_url       'https://github.com/osuosl-cookbooks/proxytrack'
description      'Installs/Configures proxytrack'
version          '1.5.0'

supports 'almalinux', '~> 8.0'
supports 'almalinux', '~> 9.0'
supports 'almalinux', '~> 10.0'

# manage_epel needs yum-epel 6's yum_epel; no floor so this releases ahead of
# osl-repos, whose pinned version still needs yum-epel 5
depends 'yum-epel'
depends 'yum-osuosl'

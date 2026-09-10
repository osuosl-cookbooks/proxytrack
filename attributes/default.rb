# Off by default: this is an internal cookbook, and every OSL node runs base,
# where osl-repos already manages EPEL
default['proxytrack']['manage_epel'] = false

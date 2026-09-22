proxytrack Cookbook
===================
Installs [HTTrack](https://www.httrack.com/) and provides a `proxytrack` custom
resource that serves pre-built HTTrack website archives over HTTP via
`systemd`-managed `proxytrack` instances.

Requirements
------------
#### platforms
- AlmaLinux 8
- AlmaLinux 9
- AlmaLinux 10

#### chef
- Chef/Cinc 16 or later

#### cookbooks
- `yum-epel` (`>= 6.0.0`)
- `yum-osuosl`

#### packages
- `httrack` - provides the `proxytrack` binary, installed from EPEL

Attributes
----------
#### proxytrack::default

| Key | Type | Description | Default |
| --- | ---- | ----------- | ------- |
| `['proxytrack']['manage_epel']` | Boolean | Whether this cookbook configures the EPEL repository. Set to `false` on nodes where EPEL is already managed elsewhere. | `true` |

Recipes
-------
#### proxytrack::default
Configures the EPEL repository (unless `['proxytrack']['manage_epel']` is set to
`false`) and the OSUOSL repository, then installs the `httrack` package.

This recipe is included automatically by the `proxytrack` resource, so it does
not normally need to be added to a run list directly.

Resources
---------
#### proxytrack
Serves one or more HTTrack archive files as a `proxytrack` instance, managed by
a `proxytrack-<name>.service` systemd unit.

##### Actions

| Action | Description |
| ------ | ----------- |
| `:create` | *(default)* Create the systemd unit, then enable and start the service |
| `:restart` | Restart the service |
| `:delete` | Stop and disable the service, then remove the systemd unit |

##### Properties

| Property | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| `proxy_address` | String | `'127.0.0.1'` | Address the HTTP proxy listens on |
| `proxy_port` | Integer | `8081` | Port the HTTP proxy listens on |
| `icp_address` | String | `'127.0.0.1'` | Address the ICP listener binds to |
| `icp_port` | Integer | `3131` | Port the ICP listener binds to |
| `httrack_file_paths` | Array | *none* | Paths to the HTTrack archive files to serve. Required for `:create` |
| `user` | String | `'nobody'` | User the service runs as |

The resource name is used as the archive/instance name and determines the
systemd unit name. `httrack_file_paths` is sorted before being passed to
`proxytrack`, so reordering the array does not cause the unit to be rewritten.
Changes to the unit notify a restart of the corresponding service.

Usage
-----
Serve an archive, listening on all interfaces:

```ruby
proxytrack 'test.com' do
  proxy_address '0.0.0.0'
  proxy_port 8080
  icp_address '0.0.0.0'
  icp_port 3130
  httrack_file_paths %w(/data/archives/test.com/hts-cache/new.zip)
end
```

Remove an instance that is no longer needed:

```ruby
proxytrack 'delete.com' do
  action :delete
end
```

Skip EPEL management when another cookbook already configures it:

```ruby
node.default['proxytrack']['manage_epel'] = false
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2020-2026, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

resource_name :proxytrack

default_action :create

property :proxy_address,      String, default: 'localhost'
property :proxy_port,         Integer
property :icp_address,        String, default: 'localhost'
property :icp_port,           Integer
property :httrack_file_paths, Array
property :user,               String, default: 'nobody'

action :create do
  run_context.include_recipe 'proxytrack::default'

  systemd_unit "proxytrack-#{new_resource.name}.service" do
    content <<-EOF.gsub(/^\s+/, '')
    [Unit]
    Description=Serve #{new_resource.name} archive

    [Service]
    Type=simple
    Restart=always
    RestartSec=1
    User=#{user}
    ExecStart=/bin/proxytrack #{new_resource.proxy_address}:#{new_resource.proxy_port} #{new_resource.icp_address}:#{new_resource.icp_port} #{new_resource.httrack_file_paths.join(' ')}

    [Install]
    WantedBy=multi-user.target
    EOF
    action [:create, :start, :enable]
  end
end

action :start do
  service "proxytrack-#{new_resource.name}" do
    action :start
  end
end

action :enable do
  service "proxytrack-#{new_resource.name}" do
    action :enable
  end
end

action :stop do
  service "proxytrack-#{new_resource.name}" do
    action :stop
  end
end

action :disable do
  action_stop
  service "proxytrack-#{new_resource.name}" do
    action :disable
  end
end

action :delete do
  action_disable
  systemd_unit "proxytrack-#{new_resource.name}.service" do
    action :delete
  end

  new_resource.httrack_file_paths.each do |p|
    directory(p[/.*#{new_resource.name}/]) do
      action :delete
      recursive true
      only_if { ::File.exist?(p) }
    end
  end
end

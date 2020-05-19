resource_name :proxytrack

default_action :create

property :proxy_address,      String, default: '127.0.0.1'
property :proxy_port,         Integer, default: 8081
property :icp_address,        String, default: '127.0.0.1'
property :icp_port,           Integer, default: 3131
property :httrack_file_paths, Array, required: true
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
    User=#{new_resource.user}
    ExecStart=/bin/proxytrack #{new_resource.proxy_address}:#{new_resource.proxy_port} #{new_resource.icp_address}:#{new_resource.icp_port} #{new_resource.httrack_file_paths.sort.join(' ')}

    [Install]
    WantedBy=multi-user.target
    EOF
    action [:create]
    notifies :restart, "service[proxytrack-#{new_resource.name}]"
  end

  service "proxytrack-#{new_resource.name}" do
    action [:enable, :start]
  end
end

action :delete do
  service "proxytrack-#{new_resource.name}" do
    action [:stop, :disable]
  end

  systemd_unit "proxytrack-#{new_resource.name}.service" do
    action [:delete]
  end
end

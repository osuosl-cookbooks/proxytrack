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
    User=#{new_resource.user}
    ExecStart=/bin/proxytrack #{new_resource.proxy_address}:#{new_resource.proxy_port} #{new_resource.icp_address}:#{new_resource.icp_port} #{new_resource.httrack_file_paths.join(' ')}

    [Install]
    WantedBy=multi-user.target
    EOF
    action [:create, :start, :enable]
  end
end

action :delete do
  systemd_unit "proxytrack-#{new_resource.name}.service" do
    action [:stop, :disable, :delete]
  end
end

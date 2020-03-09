#
# Cookbook:: proxytrack-test
# Recipe:: resource_test
#
# Copyright:: 2020, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

%w(test stop delete ).each do |d|
  remote_directory "/data/archives/#{d}.com" do
    source 'test.com'
    recursive true
  end
end

proxytrack 'test.com' do
  proxy_address '0.0.0.0'
  proxy_port 8080
  icp_address '0.0.0.0'
  icp_port 3130
  httrack_file_paths %w(/data/archives/test.com/hts-cache/new.zip)
  action :create
end

proxytrack 'delete.com' do
  proxy_address 'localhost'
  proxy_port 8081
  icp_address 'localhost'
  icp_port 3131
  httrack_file_paths %w(/data/archives/delete.com/hts-cache/new.zip)
  action [:create, :delete]
end

require_relative '../spec_helper.rb'

describe 'proxytrack-test::resource_test' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      let(:runner) do
        ChefSpec::SoloRunner.new(
          p.dup.merge(step_into: ['proxytrack'])
        )
      end
      let(:node) { runner.node }
      cached(:chef_run) { runner.converge(described_recipe) }

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { expect(chef_run).to include_recipe('yum-epel') }
      it { expect(chef_run).to install_package('httrack') }

      %w(test stop delete).each do |s|
        it do
          expect(chef_run).to create_remote_directory("/data/archives/#{s}.com").with(
            source: 'test.com',
            recursive: true
          )
        end
      end

      it do
        expect(chef_run).to create_proxytrack('test.com').with(
          proxy_address: 'localhost',
          proxy_port: 8080,
          icp_address: 'localhost',
          icp_port: 3130,
          httrack_file_paths: %w(/data/archives/test.com/hts-cache/new.zip),
          action: [:create, :start, :enable]
        )
      end
      it do
        expect(chef_run).to create_proxytrack('stop.com').with(
          proxy_address: 'localhost',
          proxy_port: 8081,
          icp_address: 'localhost',
          icp_port: 3131,
          httrack_file_paths: %w(/data/archives/stop.com/hts-cache/new.zip),
          action: [:create, :stop]
        )
      end
      it do
        expect(chef_run).to create_proxytrack('delete.com').with(
          proxy_address: 'localhost',
          proxy_port: 8082,
          icp_address: 'localhost',
          icp_port: 3132,
          httrack_file_paths: %w(/data/archives/delete.com/hts-cache/new.zip),
          action: [:create, :delete]
        )
      end
    end
  end
end

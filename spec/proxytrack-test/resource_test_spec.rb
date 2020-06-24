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

      %w(test delete).each do |s|
        it do
          expect(chef_run).to create_remote_directory("/data/archives/#{s}.com").with(
            source: 'test.com',
            recursive: true
          )
        end
        it do
          expect(chef_run.remote_directory("/data/archives/#{s}.com")).to notify('proxytrack[test.com]').to(:restart)
        end
      end

      it do
        expect(chef_run).to create_proxytrack('test.com').with(
          proxy_address: '0.0.0.0',
          proxy_port: 8080,
          icp_address: '0.0.0.0',
          icp_port: 3130,
          httrack_file_paths: %w(/data/archives/test.com/hts-cache/new.zip),
          action: [:create]
        )
      end
      it { expect(chef_run).to create_systemd_unit('proxytrack-test.com.service') }
      it { expect(chef_run.systemd_unit('proxytrack-test.com.service')).to notify('service[proxytrack-test.com]').to(:restart) }

      it { expect(chef_run).to enable_service('proxytrack-test.com') }
      it { expect(chef_run).to start_service('proxytrack-test.com') }

      it do
        expect(chef_run).to delete_proxytrack('delete.com')
      end
      it { expect(chef_run).to delete_systemd_unit('proxytrack-delete.com.service') }
      it { expect(chef_run).to stop_service('proxytrack-delete.com') }
      it { expect(chef_run).to disable_service('proxytrack-delete.com') }
    end
  end
end

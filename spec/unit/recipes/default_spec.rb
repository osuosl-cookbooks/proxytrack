require_relative '../../spec_helper'

describe 'proxytrack::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it { expect(chef_run).to create_yum_epel('default') }
      it { expect(chef_run).to include_recipe('yum-osuosl') }
      it { expect(chef_run).to install_package('httrack') }

      context 'manage_epel disabled' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['proxytrack']['manage_epel'] = false
          end.converge(described_recipe)
        end

        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
        it { expect(chef_run).to_not create_yum_epel('default') }
        it { expect(chef_run).to include_recipe('yum-osuosl') }
        it { expect(chef_run).to install_package('httrack') }
      end
    end
  end
end

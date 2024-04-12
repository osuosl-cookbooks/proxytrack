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
      it { expect(chef_run).to include_recipe('yum-epel') }
      case p
      when CENTOS_7
        it { expect(chef_run).to_not include_recipe('yum-osuosl') }
      when ALMA_8
        it { expect(chef_run).to include_recipe('yum-osuosl') }
      end
      it { expect(chef_run).to install_package('httrack') }
    end
  end
end

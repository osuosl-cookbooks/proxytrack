# InSpec test for recipe proxytrack::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe yum.repo('epel') do
  it { should exist }
  it { should be_enabled }
end

describe package('httrack') do
  it { should be_installed }
end

test_port = 8080
%w(test delete).each do |s|
  describe file("/data/archives/#{s}.com/hts-cache/new.zip") do
    it { should exist }
  end

  describe service("proxytrack-#{s}.com") do
    case s
    when 'test'
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    when 'delete'
      it { should_not be_installed }
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end

  describe file("/etc/systemd/system/proxytrack-#{s}.com.service") do
    s == 'test' ? it { should exist } : it { should_not exist }
  end

  case s
  when 'test'
    describe http("0.0.0.0:#{test_port}", headers: { Host: 'cfsummit.com' }) do
      its('status') { should cmp 200 }
    end
  when 'delete'
    describe http("localhost:#{test_port}", headers: { Host: 'cfsummit.com' }) do
      its('status') { should cmp nil }
    end
  end
  test_port += 1
end

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
%w(test stop delete).each do |s|
  describe file("/data/archives/#{s}.com/hts-cache/new.zip") do
    case s
    when 'test', 'stop'
      it { should exist }
    when 'delete'
      it { should_not exist }
    end
  end

  describe service("proxytrack-#{s}.com") do
    case s
    when 'test'
      it { should be_enabled }
      it { should be_running }
    when 'stop'
      it { should be_enabled }
      it { should_not be_running }
    when 'delete'
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end

  describe file("/data/archives/#{s}.com/hts-cache/new.zip") do
    case s
    when 'test', 'stop'
      it { should exist }
    when 'delete'
      it { should_not exist }
    end
  end

  case s
  when 'test'
    describe http("0.0.0.0:#{test_port}", headers: { Host: 'cfsummit.com' }) do
      its('status') { should cmp 200 }
    end
  when 'stop', 'delete'
    describe http("localhost:#{test_port}", headers: { Host: 'cfsummit.com' }) do
      its('status') { should cmp nil }
    end
  end
  test_port += 1
end

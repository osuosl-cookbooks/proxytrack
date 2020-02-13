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

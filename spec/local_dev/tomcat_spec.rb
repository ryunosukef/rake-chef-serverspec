require 'spec_helper'

describe package('tomcat6') do
  it { should be_installed }
end

describe service('tomcat6') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port(8080) do
  it { should be_listening }
end

describe file('/etc/tomcat6/server.xml') do
  it { should be_file }
end

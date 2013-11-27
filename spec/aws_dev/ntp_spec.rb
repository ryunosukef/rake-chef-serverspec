require 'spec_helper'

describe package('ntp') do
  it { should be_installed }
end

describe service('ntpd') do
  it { should be_enabled   }
  it { should be_running   }
end

describe file('/etc/ntp.conf') do
  it { should be_file }
end

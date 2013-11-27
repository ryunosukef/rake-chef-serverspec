#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package 'ntp'

template '/etc/ntp.conf' do
  source    'ntp.conf.erb'
  notifies  :restart, 'service[ntpd]'
end

service 'ntpd' do
  action [:enable, :start]
end

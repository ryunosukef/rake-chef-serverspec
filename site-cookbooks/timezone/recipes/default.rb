#
# Cookbook Name:: timezone
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'chef/util/file_edit'

link "/etc/localtime" do
  to "/usr/share/zoneinfo/Asia/Tokyo"
end

clock = Chef::Util::FileEdit.new("/etc/sysconfig/clock")
clock.search_file_replace_line(/^ZONE=.*$/, "ZONE=Asia/Tokyo")
clock.write_file
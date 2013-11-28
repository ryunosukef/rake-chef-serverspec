require 'spec_helper'

 describe command( ' date | grep JST ') do
   it { should return_exit_status 0 }
 end

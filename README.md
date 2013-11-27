vagrant-aws-sample
==================

[■[AWS][Vagrant]vagrant-awsを利用したイイカンジ（？）のAWS開発フロー](http://d.hatena.ne.jp/toritori0318/20130916/1379355060)を参照しながら、vagrant を使ってAWS上に環境構築してみる

vagrant pluginをインストールしておく
-------
```
vagrant plugin install vagrant-aws
vagrant plugin install vagrant-ami
vagrant plugin install vagrant-omnibus
```

こんな感じでインストールできましたよ　と

```
$ vagrant plugin list
vagrant-ami (0.0.1)
vagrant-aws (0.4.0)
vagrant-omnibus (1.1.2)
```

vagrant box をインストールしておく
-------

```
vagrant box add centos https://github.com/2creatives/vagrant-centos/releases/download/v0.1.0/centos64-x86_64-20131030.box
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
```

```
$ vagrant box list
centos (virtualbox)
dummy  (aws)
```


local環境で、vagrant up/ssh/provision/destroy
-------

- vagrant コマンドを使って、まずは動作を確認する

```
$ vagrant up local
Bringing machine 'local' up with 'virtualbox' provider...
[local] Importing base box 'centos'...
[local] Matching MAC address for NAT networking...
[local] Setting the name of the VM...
[local] Clearing any previously set forwarded ports...
[local] Creating shared folders metadata...
[local] Clearing any previously set network interfaces...
[local] Preparing network interfaces based on configuration...
[local] Forwarding ports...
[local] -- 22 => 2222 (adapter 1)
[local] -- 80 => 8080 (adapter 1)
[local] Booting VM...
[local] Waiting for machine to boot. This may take a few minutes...
[local] Machine booted and ready!
[local] The guest additions on this VM do not match the installed version of
VirtualBox! In most cases this is fine, but in rare cases it can
cause things such as shared folders to not work properly. If you see
shared folder errors, please update the guest additions within the
virtual machine and reload your VM.

Guest Additions Version: 4.3.0
VirtualBox Version: 4.2
[local] Configuring and enabling network interfaces...
[local] Mounting shared folders...
[local] -- /vagrant
[local] -- /tmp/vagrant-chef-1/chef-solo-3/roles
[local] -- /tmp/vagrant-chef-1/chef-solo-2/cookbooks
[local] -- /tmp/vagrant-chef-1/chef-solo-1/cookbooks
[local] -- /tmp/vagrant-chef-1/chef-solo-4/data_bags
[local] Installing Chef 11.8.0 Omnibus package...
[local] Downloading Chef 11.8.0 for el...
...
... (中略)
...

[local] 
[local] Thank you for installing Chef!
[local] Running provisioner: chef_solo...
Generating chef JSON and uploading...
[local] Warning: Chef run list is empty. This may not be what you want.
Running chef-solo...
[2013-11-25T07:57:56+00:00] INFO: Forking chef instance to converge...
[2013-11-25T07:57:56+00:00] INFO: *** Chef 11.8.0 ***
[2013-11-25T07:57:56+00:00] INFO: Chef-client pid: 2460
[2013-11-25T07:57:57+00:00] INFO: Run List is []
[2013-11-25T07:57:57+00:00] INFO: Run List expands to []
[2013-11-25T07:57:57+00:00] INFO: Starting Chef Run for vagrant-centos64
[2013-11-25T07:57:57+00:00] INFO: Running start handlers
[2013-11-25T07:57:57+00:00] INFO: Start handlers complete.
[2013-11-25T07:57:57+00:00] INFO: Chef Run complete in 0.024771155 seconds
[2013-11-25T07:57:57+00:00] INFO: Running report handlers
[2013-11-25T07:57:57+00:00] INFO: Report handlers complete
[2013-11-25T07:57:56+00:00] INFO: Forking chef instance to converge...
```

```
$ vagrant status
Current machine states:

local                     running (virtualbox)
aws_srv_dev               not created (virtualbox)
aws_srv_prd_wap           not created (virtualbox)
aws_srv_prd_redis         not created (virtualbox)
```

```
$ vagrant destroy local
Are you sure you want to destroy the 'local' VM? [y/N] y
[local] Forcing shutdown of VM...
[local] Destroying VM and associated drives...
[local] Running cleanup tasks for 'chef_solo' provisioner...
```

```
$ vagrant status local
Current machine states:

local                     not created (virtualbox)
```

と、一連の流れをおさえたので、次は、rakeコマンドで、上記の流れを再現してみる

- rake コマンドでlocal環境をvagrant up/destroy

```
$ rake local:up
vagrant up local --no-provision
Bringing machine 'local' up with 'virtualbox' provider...
[local] Importing base box 'centos'...
[local] Matching MAC address for NAT networking...
[local] Setting the name of the VM...
[local] Clearing any previously set forwarded ports...
[local] Creating shared folders metadata...
[local] Clearing any previously set network interfaces...
[local] Preparing network interfaces based on configuration...
[local] Forwarding ports...
[local] -- 22 => 2222 (adapter 1)
[local] -- 80 => 8080 (adapter 1)
[local] Booting VM...
[local] Waiting for machine to boot. This may take a few minutes...
[local] Machine booted and ready!
[local] The guest additions on this VM do not match the installed version of
VirtualBox! In most cases this is fine, but in rare cases it can
cause things such as shared folders to not work properly. If you see
shared folder errors, please update the guest additions within the
virtual machine and reload your VM.

Guest Additions Version: 4.3.0
VirtualBox Version: 4.2
[local] Configuring and enabling network interfaces...
[local] Mounting shared folders...
[local] -- /vagrant
[local] -- /tmp/vagrant-chef-1/chef-solo-3/roles
[local] -- /tmp/vagrant-chef-1/chef-solo-2/cookbooks
[local] -- /tmp/vagrant-chef-1/chef-solo-1/cookbooks
[local] -- /tmp/vagrant-chef-1/chef-solo-4/data_bags
[local] Installing Chef 11.8.0 Omnibus package...
[local] Downloading Chef 11.8.0 for el...
...
... (中略)
...
[local] 
[local] Thank you for installing Chef!
```

```
$ vagrant status 
Current machine states:

local                     running (virtualbox)
aws_srv_dev               not created (virtualbox)
aws_srv_prd_wap           not created (virtualbox)
aws_srv_prd_redis         not created (virtualbox)
```

localなVMあがりましたね

```
$ rake local:provision
vagrant provision local
[local] Chef 11.8.0 Omnibus package is already installed.
[local] Running provisioner: chef_solo...
Generating chef JSON and uploading...
Running chef-solo...
[2013-11-25T08:09:18+00:00] INFO: Forking chef instance to converge...
[2013-11-25T08:09:18+00:00] INFO: *** Chef 11.8.0 ***
[2013-11-25T08:09:18+00:00] INFO: Chef-client pid: 2500
[2013-11-25T08:09:19+00:00] INFO: Setting the run_list to ["recipe[echo]"] from JSON
[2013-11-25T08:09:19+00:00] INFO: Run List is [recipe[echo]]
[2013-11-25T08:09:19+00:00] INFO: Run List expands to [echo]
[2013-11-25T08:09:19+00:00] INFO: Starting Chef Run for vagrant-centos64
[2013-11-25T08:09:19+00:00] INFO: Running start handlers
[2013-11-25T08:09:19+00:00] INFO: Start handlers complete.
[2013-11-25T08:09:19+00:00] INFO: ============= [local_provision] dayo! ====================
[2013-11-25T08:09:19+00:00] INFO: Chef Run complete in 0.043259923 seconds
[2013-11-25T08:09:19+00:00] INFO: Running report handlers
[2013-11-25T08:09:19+00:00] INFO: Report handlers complete
[2013-11-25T08:09:18+00:00] INFO: Forking chef instance to converge...
```

echo のレシピが適用されました


```
$ rake local:destroy
vagrant destroy -f local
[local] Forcing shutdown of VM...
[local] Destroying VM and associated drives...
[local] Running cleanup tasks for 'chef_solo' provisioner...
```

localなVMさん、さようなら　(Rakefileに-fをつけました)


AWS環境で、vagrant up/ssh/provision/destroy
-------

```
$ rake aws:up vm=aws_srv_dev
vagrant up aws_srv_dev --provider=aws --no-provision
Bringing machine 'aws_srv_dev' up with 'aws' provider...
WARNING: Nokogiri was built against LibXML version 2.8.0, but has dynamically loaded 2.9.1
[aws_srv_dev] Warning! The AWS provider doesn't support any of the Vagrant
high-level network configurations (`config.vm.network`). They
will be silently ignored.
[aws_srv_dev] Launching an instance with the following settings...
[aws_srv_dev]  -- Type: t1.micro
[aws_srv_dev]  -- AMI: ami-5769f956
[aws_srv_dev]  -- Region: ap-northeast-1
[aws_srv_dev]  -- Availability Zone: ap-northeast-1a
[aws_srv_dev]  -- Keypair: aws
[aws_srv_dev]  -- User Data: yes
[aws_srv_dev]  -- Security Groups: ["default"]
[aws_srv_dev]  -- User Data: #!/bin/bash
echo 'Defaults:ec2-user !requiretty' > /etc/sudoers.d/999-vagrant-cloud-init-requiretty && cpsod 440 /etc/sudoers.d/999-vagrant-cloud-init-requiretty
[aws_srv_dev]  -- Block Device Mapping: []
[aws_srv_dev]  -- Terminate On Shutdown: false
[aws_srv_dev] Waiting for instance to become "ready"...
[aws_srv_dev] Waiting for SSH to become available...
[aws_srv_dev] Machine is booted and ready for use!
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/ => /vagrant
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/cookbooks/ => /tmp/vagrant-chef-1/chef-solo-1/cookbooks
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/site-cookbooks/ => /tmp/vagrant-chef-1/chef-solo-2/cookbooks
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/roles/ => /tmp/vagrant-chef-1/chef-solo-3/roles
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/data_bags/ => /tmp/vagrant-chef-1/chef-solo-4/data_bags
[aws_srv_dev] Installing Chef 11.8.0 Omnibus package...
[aws_srv_dev] Downloading Chef 11.8.0 for el...
[aws_srv_dev] Installing Chef 11.8.0
...
...
...
[aws_srv_dev] 
[aws_srv_dev] Thank you for installing Chef!
```

```
$ rake aws:provision vm=aws_srv_dev
vagrant provision aws_srv_dev
WARNING: Nokogiri was built against LibXML version 2.8.0, but has dynamically loaded 2.9.1
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/ => /vagrant
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/cookbooks/ => /tmp/vagrant-chef-1/chef-solo-1/cookbooks
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/site-cookbooks/ => /tmp/vagrant-chef-1/chef-solo-2/cookbooks
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/roles/ => /tmp/vagrant-chef-1/chef-solo-3/roles
[aws_srv_dev] Rsyncing folder: /Users/fujimoto/aws/vagrant-aws-sample/data_bags/ => /tmp/vagrant-chef-1/chef-solo-4/data_bags
[aws_srv_dev] Chef 11.8.0 Omnibus package is already installed.
[aws_srv_dev] Running provisioner: chef_solo...
Generating chef JSON and uploading...
Running chef-solo...
[2013-11-25T03:24:05-05:00] INFO: Forking chef instance to converge...
[2013-11-25T03:24:06-05:00] INFO: *** Chef 11.8.0 ***
[2013-11-25T03:24:06-05:00] INFO: Chef-client pid: 2825
[2013-11-25T03:24:12-05:00] INFO: Setting the run_list to ["recipe[echo]"] from JSON
[2013-11-25T03:24:12-05:00] INFO: Run List is [recipe[echo]]
[2013-11-25T03:24:12-05:00] INFO: Run List expands to [echo]
[2013-11-25T03:24:12-05:00] INFO: Starting Chef Run for ip-10-166-2-219.ap-northeast-1.compute.internal
[2013-11-25T03:24:12-05:00] INFO: Running start handlers
[2013-11-25T03:24:12-05:00] INFO: Start handlers complete.
[2013-11-25T03:24:12-05:00] INFO: ============= [aws_srv_dev] dayo! ====================
[2013-11-25T03:24:12-05:00] INFO: Chef Run complete in 0.006888611 seconds
[2013-11-25T03:24:12-05:00] INFO: Running report handlers
[2013-11-25T03:24:12-05:00] INFO: Report handlers complete
[2013-11-25T03:24:05-05:00] INFO: Forking chef instance to converge...
```

```
$ vagrant ssh aws_srv_dev
[ec2-user@ip-10-166-xx-xx ~]$ 
[ec2-user@ip-10-166-xx-xx ~]$ ls /vagrant/
LICENSE  README.md  Rakefile  cookbooks  data_bags  nodes  roles  site-cookbooks

[ec2-user@ip-10-166-xx-xx ~]$ ls /tmp/vagrant-chef-1/
chef-solo-1/ chef-solo-2/ chef-solo-3/ chef-solo-4/ dna.json     solo.rb

[ec2-user@ip-10-166-xx-xx ~]$ exit
$ 
```

```
$ rake aws:destroy vm=aws_srv_dev
vagrant destroy -f aws_srv_dev
[aws_srv_dev] Terminating the instance...
```


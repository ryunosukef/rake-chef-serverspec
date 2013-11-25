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



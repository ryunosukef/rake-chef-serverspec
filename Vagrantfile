# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # install chef
  config.omnibus.chef_version = "11.6.0"

  # local dev 
  config.vm.define :local_dev do |local_dev|
    local_dev.vm.box = "centos"
    local_dev.vm.network :forwarded_port, guest: 80, host: 8080
    local_dev.vm.network :private_network, ip: "192.168.33.10"
  end

  # local stg 
  config.vm.define :local_stg do |local_stg|
    local_stg.vm.box = "centos"
    local_stg.vm.network :forwarded_port, guest: 80, host: 28080
    local_stg.vm.network :private_network, ip: "192.168.33.20"
  end

  # aws dev
  config.vm.define :aws_dev do |aws_dev|
    aws_provider_setting(
      aws_dev,
      {
        'tags' => {
          'Name'         => 'dev',
          'environments' => 'development',
        },
        #'ami' => 'ami-xxxxxxxxxxxxx', # custom-base-ami
        #'instance_type' => 'c1.xlarge',
        #'security_groups' => ['base', 'production']
      }
    )
  end

  # aws stg
  config.vm.define :aws_stg do |aws_stg|
    aws_provider_setting(
      aws_stg,
      {
        'tags' => {
          'Name'         => 'stg',
          'environments' => 'staging',
        },
        #'ami' => 'ami-xxxxxxxxxxxxx', # custom-base-ami
        #'instance_type' => 'c1.xlarge',
        #'security_groups' => ['base', 'production']
      }
    )
  end

  # provisioning chef-solo
  config.vm.provision :chef_solo do |chef|
    # .chef/knife.rbと同じ内容
    chef.cookbooks_path = ["./cookbooks", "./site-cookbooks"]
    chef.roles_path = "./roles"
    chef.data_bags_path = "./data_bags"
#    chef.encrypted_data_bag_secret_key_path = '.data_bag_key'
    # chef jsonファイル読み込み
    begin
      fname = ENV["chef_json"]
      nodes_json = (fname) ? JSON.parse(File.read(fname)) : {'recipes'=>{}}
      # node.jsonの情報を登録
      nodes_json["recipes"].each do |run|
        case run
        when /^recipe\[(\w+)\]/
          chef.add_recipe($1)
        when /^role\[(\w+)\]/
          chef.add_role($1)
        else
          chef.add_recipe(run)
        end
      end
      # delete recipes key
      nodes_json.delete("recipes")
      # add attrubute
      chef.json = nodes_json
    rescue => ex
      $stderr.puts "#{ex} (#{ex.class})"
    end
  end

end

# aws setting
def aws_provider_setting vagrant_aws, setting
  tags              = setting['tags'] || {}
  ami               = setting['ami'] || ENV['AWS_AMI'] || 'ami-5769f956'
  keypair_name      = setting['keypair_name'] || 'aws'
  instance_type     = setting['instance_type'] || 't1.micro'
  region            = setting['region'] || 'ap-northeast-1'
  availability_zone = setting['availability_zone'] || 'ap-northeast-1a'
  security_groups   = setting['security_groups'] || ['default']
  private_key_path  = setting['private_key_path'] || ENV['AWS_KEY_PATH'] || '.ssh/aws.pem'
  ssh_username      = ENV["CHEF_USER"] || setting['ssh_username'] || 'ec2-user'

  # aws provider
  vagrant_aws.vm.provider :aws do |aws, override|
    aws.tags              = tags
    aws.ami               = ami
    aws.access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws.keypair_name      = keypair_name
    aws.instance_type     = instance_type
    aws.region            = region
    aws.availability_zone = availability_zone
    aws.security_groups   = security_groups
    # requiretty対策
    commands = [
      "#!/bin/bash",
      "echo 'Defaults:ec2-user !requiretty' > /etc/sudoers.d/999-vagrant-cloud-init-requiretty && cpsod 440 /etc/sudoers.d/999-vagrant-cloud-init-requiretty",
    ]
    aws.user_data = commands.join("\n")
    # override
    override.ssh.username = ssh_username
    override.ssh.private_key_path = private_key_path
  end

  vagrant_aws.vm.box = "dummy"
  vagrant_aws.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
end

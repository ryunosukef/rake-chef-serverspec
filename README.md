rake-chef-serverspec
==================
[![wercker status](https://app.wercker.com/status/4b11b1cbe5dd2e29d9a312b27f37fb6b/m "wercker status")](https://app.wercker.com/project/bykey/4b11b1cbe5dd2e29d9a312b27f37fb6b)

[vagrant-aws-sample](https://github.com/ryunosukef/vagrant-aws-sample)
と
[jenkins-vagrant-test](https://github.com/ryunosukef/jenkins-vagrant-test)
をもとに、rakeを駆使しながら、chef/serverspecのコードを作っていく


rake 構文
---------
<env>によってlocal環境とaws環境を使い分け、
<vm_name>によって、適用するrecipe/serverspecを使い分ける

```
rake <env>:<operation> vm=<vm_name>
  
  <env>: local, aws
  <operation>: up, provision, spec, destroy
  <vm_name>: local_dev, local_stg, aws_dev, aws_stg
```

Rakefile
--------

```
$ rake local:spec
rspec spec/local/*
....

Finished in 0.31876 seconds
4 examples, 0 failures
```

こんな感じで実行できるように、Rakefileを修正

```
  desc "Local: serverspec実行"
  task :spec do
    ENV['chef_json'] = build_json_name('local')
    sh "rspec spec/local/*"
  end
```

あとは、recipeとspecを相互に追加していく


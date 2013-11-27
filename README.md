rake-chef-serverspec
==================

[vagrant-aws-sample](https://github.com/ryunosukef/vagrant-aws-sample)
と
[jenkins-vagrant-test](https://github.com/ryunosukef/jenkins-vagrant-test)
をもとに、rakeを駆使しながら、chef/serverspecのコードを作っていく


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
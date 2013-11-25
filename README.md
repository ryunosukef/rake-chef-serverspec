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



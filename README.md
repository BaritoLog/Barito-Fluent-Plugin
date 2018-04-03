# fluent-plugin-barito

[![Build Status](https://travis-ci.org/BaritoLog/Barito-Fluent-Plugin.svg?branch=master)](https://travis-ci.org/BaritoLog/Barito-Fluent-Plugin)

[Fluentd](https://fluentd.org/) output plugin for [BaritoLog](https://github.com/BaritoLog).

## Installation

### RubyGems

```
$ gem install fluent-plugin-barito
```

### Bundler

Add following line to your Gemfile:

```ruby
gem 'fluent-plugin-barito'
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-config-format output barito
```

You can copy and paste generated documents here.

### Fluentd configuration example

## Without Kubernetes

Use type `barito_vm` for deployment without kubernetes

```conf
<source>
  @type tail
  tag "barito"
  path /path/to/file.log
</source>

<match barito>
  @type barito_vm

  application_secret "ABCDE1234"
  produce_url "http://receiver-host:receiver-port/str/1/st/2/fw/3/cl/4/produce/some-topic"
  <buffer>
    flush_mode immediate
  </buffer>
</match>
```

## With Kubernetes
Change type to `barito_k8s` and `use_kubernetes` to `true`.

```
<match barito>
  @type barito_k8s

  use_https false
  use_kubernetes true
</match>
```

and set `kubernetes labels` in YAML :

```
labels:
    baritoApplicationSecret: "ABCDE1234"
    baritoProduceHost: "receiver-host"
    baritoProducePort: "receiver-port"
    baritoProduceTopic: "some-topic"
    baritoStreamId: "1"
    baritoStoreId: "2"
    baritoForwarderId: "3"
    baritoClientId: "4"
```

## Copyright

* Copyright(c) 2018- BaritoLog
* License
  * Apache License, Version 2.0

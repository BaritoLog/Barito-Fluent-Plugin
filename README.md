# fluent-plugin-barito

[Fluentd](https://fluentd.org/) output plugin for [BaritoLog](https://github.com/BaritoLog).

## Installation

### RubyGems

```
$ gem install fluent-plugin-barito
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-barito"
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

```conf
<source>
  @type tail
  tag "barito"
  path /path/to/file.log
</source>

<match barito>
  @type barito

  use_https false
  use_kubernetes false
  application_secret "ABCDE1234"
  produce_url "http://receiver-host:receiver-port/str/1/st/2/fw/3/cl/4/produce/some-topic"
  <buffer>
    flush_mode immediate
  </buffer>
</match>
```

## With Kubernetes
If this gem used in Kubernetes daemonset, change `use_kubernetes` to `true`.

```
<match barito>
  @type barito

  use_https false
  use_kubernetes true

  application_secret "ABCDE1234"
  stream_id "1"
  store_id "2"
  client_id "3"
  forwarder_id "4"
  produce_host "receiver-host"
  produce_port "receiver-port"
  produce_topic "some-topic"
</match>
```

Or alternatively, we can set `kubernetes labels` in YAML :

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

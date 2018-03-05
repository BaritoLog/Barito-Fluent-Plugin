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
  stream_id 1
  produce_host barito-flow.local
  produce_port 8080
  produce_topic barito-topic
  store_id 2
  forwarder_id 3
  client_id 4
  <buffer>
    flush_mode immediate
  </buffer>
</match>
```

If this gem used in Kubernetes daemonset, change `use_kubernetes` to `true`.

## Copyright

* Copyright(c) 2018- BaritoLog
* License
  * Apache License, Version 2.0

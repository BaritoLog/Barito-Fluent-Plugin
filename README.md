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
  <parse>
    @type none
  </parse>
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
Change type to `barito_batch_k8s`.

```
<match kubernetes.var.log.containers.server-**.log>
  @type barito_batch_k8s
  name test_container
  cluster_name test_cluster
  application_name test_application_name
  application_group_secret xxxxxx
  produce_url https://router.barito/produce_batch
  <buffer>
    flush_at_shutdown false
    flush_thread_count 8
    flush_thread_interval 1
    flush_thread_burst_interval 1
    flush_mode interval
    flush_interval 1s
    queued_chunks_limit_size 1
    overflow_action drop_oldest_chunk
    retry_timeout 0s
    retry_max_times 0
    disable_chunk_backup true
  </buffer>
</match>
```

## Copyright

* Copyright(c) 2018- BaritoLog
* License
  * Apache License, Version 2.0

# fluent-plugin-barito

[![Build Status](https://travis-ci.org/BaritoLog/Barito-Fluent-Plugin.svg?branch=master)](https://travis-ci.org/BaritoLog/Barito-Fluent-Plugin)

[Fluentd](https://fluentd.org/) output plugin for [BaritoLog](https://github.com/BaritoLog).

## Overview

This Fluentd plugin enables you to send logs directly to Barito Log infrastructure. It supports both traditional VM deployments and Kubernetes environments with different output types optimized for each use case.

## Installation

### RubyGems

```bash
gem install fluent-plugin-barito
```

### Bundler

Add following line to your Gemfile:

```ruby
gem 'fluent-plugin-barito'
```

And then execute:

```bash
bundle install
```

## Configuration

You can generate configuration template:

```bash
fluent-plugin-config-format output barito
```

### Configuration Parameters

Before configuring the plugin, you'll need to obtain the following from your Barito Market:

- **Application Group Secret**: Your unique application group identifier
- **Produce URL**: The endpoint URL for sending logs to Barito
- **Application Name**: Your application identifier (for Kubernetes deployments)
- **Cluster Name**: Your cluster identifier (for Kubernetes deployments)

## Plugin Types

### VM/Traditional Deployment Configuration

For traditional VM deployments where logs are sent individually.

**Required Parameters:**

- `application_secret`: Your application group secret from Barito Market
- `produce_url`: The produce endpoint URL from Barito Market

Use type `barito_vm` for deployment without Kubernetes:

```xml
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

### Kubernetes Deployment Configuration

For Kubernetes deployments where logs are sent in batches for better performance.

**Required Parameters:**

- `name`: Container name identifier
- `cluster_name`: Your cluster name
- `application_name`: Your application name
- `application_group_secret`: Your application group secret from Barito Market
- `produce_url`: The batch produce endpoint URL from Barito Market

Use type `barito_batch_k8s` for Kubernetes environments:

```xml
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

## Troubleshooting

### Common Issues

1. **Connection refused**: Verify the `produce_url` is correct and accessible
2. **Authentication failed**: Check your `application_group_secret` is valid
3. **Buffer overflow**: Adjust buffer settings based on your log volume

### Debug Mode

Add the following to your Fluentd configuration for debug logging:

```xml
<system>
  log_level debug
</system>
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

- Copyright(c) 2018-2025 BaritoLog
- License: Apache License, Version 2.0

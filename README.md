# RabbitMQ Message UUID Plugin #

This plugin fills the `uuid` property of a message as it enters
RabbitMQ with the current (server node) UUID value.

## Supported RabbitMQ Versions ##

This plugin targets RabbitMQ 3.6.0 and later versions.

## Installing ##

Clone the repo and then build it with `make`:

```
cd spr-rabbitmq-message-uuid
make
# [snip]
make dist
# [snip]
ls plugins/*
```

Build artefacts then can be found under the `plugins` directory.

Finally copy `plugins/spr_rabbitmq_message_uuid.ez` to the `$RABBITMQ_HOME/plugins` folder.

## Usage ##

Just enable the plugin with the following command:

```bash
rabbitmq-plugins enable spr_rabbitmq_message_uuid
```

The plugin will then hook into the `basic.publish` process in order to
add the current timestamp as seen by the broker.

## Limitations ##

The plugin hooks into the `basic.publish` path, so expect a small
throughput reduction when using this plugin, since it has to modify
every message that crosses RabbitMQ.

If there's enough demand, we could add in the future a way for only
uuid-appended messages that crosses certain exchanges, say by applying
policies.

## LICENSE ##

See the LICENSE file

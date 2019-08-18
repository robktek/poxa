[![Build Status](https://travis-ci.org/edgurgel/poxa.svg?branch=master)](https://travis-ci.org/edgurgel/poxa)
[![Inline docs](http://inch-ci.org/github/edgurgel/poxa.svg?branch=master)](http://inch-ci.org/github/edgurgel/poxa)
[![Release](http://img.shields.io/github/release/edgurgel/poxa.svg)](https://github.com/edgurgel/poxa/releases/latest)
[![Docker](https://img.shields.io/docker/pulls/edgurgel/poxa-automated.svg)](https://hub.docker.com/r/edgurgel/poxa-automated)
# Poxa

Open Pusher implementation compatible with Pusher libraries. It's designed to be used as a single registered app with id, secret and key defined on start.

How do I speak 'poxa'?

['poʃa] - Phonetic notation

[posha] : po ( potion ), sha ( shall )

## Features

* Public channels;
* Private channels;
* Presence channels;
* Client events;
* SSL on websocket and REST API;
* Simple console;
* REST API
  * /users on presence channels
  * /channels/:channel_name
  * /channels

## Development

Poxa is a standalone elixir server implementation of the Pusher protocol.

You need [Elixir](http://elixir-lang.org) 1.9 at least and Erlang 21.0

Clone this repository

Run

```console
mix deps.get
mix compile
```

The default configuration is:

* Port: 8080
* App id: 'app_id'
* App key: 'app_key'
* App secret: 'secret'

You can run and configure these values using these environment variables:

```
PORT=8080
POXA_APP_KEY=app_key
POXA_SECRET=secret
POXA_APP_ID=app_id
```

Or you can setup a configuration file like this:

my_config.exs

```elixir
use Mix.Config

config :poxa,
  port: 4567,
  app_key: "9 2504f0f2094c66ddf61",
  app_secret: "c3e321556bff8bf10041",
  app_id: "729298",
  web_hook: "localhost:3000/pusher/webhook"
```

And run:

```console
elixir -pa _build/dev/consolidated -S mix run --config custom-config.exs --no-halt
```

And if you want SSL, try something like this on your configuration file:

```elixir
use Mix.Config

config :poxa,
  port: 4567,
  app_key: "9 2504f0f2094c66ddf61",
  app_secret: "c3e321556bff8bf10041",
  app_id: "729298",
  web_hook: "localhost:3000/pusher/webhook",
  ssl: [enabled: true,
        port: 8443,
        cacertfile: "priv/ssl/server-ca.crt",
        certfile: "priv/ssl/server.crt",
        keyfile: "priv/ssl/server.key"]
```

Optionally you can specify a payload limit. The default value is 10kb. To change it pass
```
PAYLOAD_LIMIT=20000
```
where 20000 is number of bytes.

You can also specify this value via `payload_limit` in your config file (e.g. my_config.exs) as you would for other variables.

## Release

This is the preferred way to deploy a Poxa server.

If you just want to run a release, follow these instructions:

First download dependencies and generate the release

```console
MIX_ENV=prod mix do deps.get, compile, release
```

Then you can run it using:

```console
$ _build/prod/rel/poxa/bin/poxa
Usage: poxa {start|start_boot <file>|foreground|stop|restart|reboot|ping|rpc <m> <f> [<a>]|console|console_clean|console_boot <file>|attach|remote_console|upgrade}
```

To start as daemon you just need to:

```console
$ _build/prod/rel/poxa/bin/poxa start
```

Docker images are automatically built by [Docker Hub](https://hub.docker.com/r/edgurgel/poxa-automated/builds/). They are available at Docker Hub: https://hub.docker.com/r/edgurgel/poxa-automated/tags/

One can generate it using: `docker build -t local/poxa .`.

The `docker run` command should look like this:

```
docker run --rm --name poxa -p 8080:8080 edgurgel/poxa-automated:latest
```

## Configuration

The following environment variables are supported:

* `PORT`
* `POXA_APP_KEY`
* `POXA_SECRET`
* `POXA_APP_ID`
* `POXA_REGISTRY_ADAPTER`
* `WEB_HOOK`
* `POXA_SSL`
* `SSL_PORT`
* `SSL_CACERTFILE`
* `SSL_CERTFILE`
* `SSL_KEYFILE`

## Your application

If you are using the pusher-gem:

```ruby
Pusher.host   = 'localhost'
Pusher.port   = 8080
```

And pusher-js:

```javascript

// will only use WebSockets
var pusher = new Pusher(APP_KEY, {
  wsHost: 'localhost',
  wsPort: 8080,
  enabledTransports: ["ws", "flash"],
  disabledTransports: ["flash"]
});
```

A working poxa is on http://poxa.herokuapp.com, with:

* App key: "app_key"
* App id: "app_id"
* App secret: "secret"
* Port: 80

Also a pusher example(https://github.com/pusher/pusher-presence-demo) is running using poxa at: http://poxa-presence-chat.herokuapp.com/

## Console

A simple console is available on index:

![Console](http://i.imgur.com/zEbZZgN.png)

You can see it in action on http://poxa.herokuapp.com using "app_key" and "secret" to connect. Now open the [poxa-presence-chat](http://poxa-presence-chat.herokuapp.com) and watch events happening!

## Implementation

Poxa uses [gproc](https://github.com/uwiger/gproc) extensively to register websocket connections as channels. So, when a client subscribes for channel 'example-channel', the websocket connection (which is a elixir process) is "tagged" as **{pusher, example-channel}**. When a pusher event is triggered on the 'example-channel', every websocket matching the tag receives the event.

## Contributing

If you'd like to hack on Poxa, start by forking my repo on Github.

Dependencies can be fetched running:

```console
MIX_ENV=dev mix deps.get
```

Compile:

```console
mix compile
```

The test suite used is the ExUnit and [Mimic](http://github.com/edgurgel/mimic) to mock stuff.

To run tests:

```console
mix test
```

Pull requests are greatly appreciated.

## TODO

* [ ] SockJS support;
* [x] Complete REST api;
* [x] Mimic pusher error codes;
* [x] Integration test using pusher-js or other client library;
* [x] Web hooks;
* [x] Add 'Vacated' and 'Occupied' events to Console;
* [X] Use `gproc` to generate Console events so other handlers can be attached (Web hook for example);
* [ ] Turn Poxa on a distributed server with multiple nodes;

## Pusher

Pusher is an excellent service and you should use it in production.

## Acknowledgements

Thanks to [@bastos](https://github.com/bastos) for the project name :heart:!

## Who is using it?

* [Waffle Takeout](https://takeout.waffle.io/)
* [Tinfoil Security](https://tinfoilsecurity.com/)
* Add your project/service here! Send a PR! :tada:


##Add-on config
In case `_build/prod/rel/poxa/releases/0.8.1/poxa.conf` not existed, Change config in `_build/prod/rel/poxa/releases/0.8.1/sys.config`

Default config for poxa
```
# HTTP Port
# If not set, will use value of PORT environment variable
poxa.port = 4567

# Pusher app key
# If not set, will use value of POXA_APP_KEY environment variable
poxa.app_key = "92504f0f2094c66ddf61"

# Pusher secret
# If not set, will use value of POXA_SECRET environment variable
poxa.app_secret = "c3e321556bff8bf10041"

# Pusher app id
# If not set, will use value of POXA_APP_ID environment variable
poxa.app_id = "729298"

# Registry adapter
# If not set, will use value of POXA_REGISTRY_ADAPTER environment variable
poxa.registry_adapter = "gproc"

# Web hook endpoint
# If not set, will use value of WEB_HOOK environment variable
poxa.web_hook = "http://10.148.0.11:3000/pusher/webhook"
```

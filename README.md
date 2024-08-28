# Formular Server

Formular Server is an HTTP server built on top of Phoenix, designed to manage application configurations efficiently.

[Online demo](https://formular-server-ose.fly.dev) (requiring Google account to sign in)

## Managing Configurations

Configurations in Formular Server can be managed through either a web UI or an API, providing flexibility depending on your preferred interface.

The configuration can be in one of the following formats:

* raw Elixir code, or
* [Tablex](https://github.com/elixir-tablex/tablex) (decision table)


## Consuming Configurations

Applications can connect to a Formular Server using the [formular-client](https://github.com/qhwa/formular-client) over WebSocket connections. This allows them to receive the latest configuration updates automatically when new versions are available.

### Collaboration Diagram

The following diagram illustrates the interaction between your application and the Formular Server:

```
      Users
        │
        │ uses
        │
        ▼

      │My Application                                   Formular Server
┌─────┴──────────────────┐                          ┌──────────────────────────┐
│                        │                          │                          │
│ MyMod1    ┌──────────┐ │        watches           │   "my function code 1"   │
│ MyMod2    │Formular  └─┼──────────────────────────►   "my function code 2"   │
│ MyMod3◄───┤Client    ◄─┼──────────────────────────┐   "my function code 3"   │
│ ...       └──────────┘ │                          │   ...                    │
│                        │                          │                          │
└────────────────────────┘                          └──────────▲───────────────┘
                                                               │
                                                               │ updates
                                                               │
                                                               ▼

                                                           Developer
```

## User Authentication

Currently, Formular Server supports Google OAuth for user authentication. Additional OAuth providers may be supported in the future based on demand.

### OAuth Providers

At present, Formular Server integrates with Google as the OAuth 2.0 provider. To configure this, you can set the following environment variables:

```sh
GOOGLE_CLIENT_ID="..."
GOOGLE_CLIENT_SECRET="..."
# Optionally, specify allowed domains, separated by commas:
# GOOGLE_ALLOWED_DOMAINS="example.com,mycompany.com"
```

## Environment Variables

[Include a list of other relevant environment variables here, if applicable.]

## Running Locally

### Prerequisites

Before running Formular Server locally, ensure you have the following installed:

- [ASDF](https://asdf-vm.com/guide/getting-started.html) (recommended)
- Elixir & Erlang (install via ASDF: `asdf install`)
- PostgreSQL

### Install Dependencies

To install the necessary dependencies, run:

```sh
mix deps.get
```

### Set Up Database

To create and migrate your database, use:

```sh
mix ecto.setup
```

### Start the Server

To start the Phoenix server, execute:

```sh
mix phx.server
```

Alternatively, you can start the server within IEx:

```sh
iex -S mix phx.server
```

After the server is running, visit [http://localhost:4000](http://localhost:4000) in your browser to access the application.

### Production Deployment

For deployment in a production environment, please refer to [Phoenix's deployment guides](https://hexdocs.pm/phoenix/deployment.html).

[![Hex.pm Version](http://img.shields.io/hexpm/v/divo_postgres.svg?style=flat)](https://hex.pm/packages/divo_postgres)

# Divo Postgres

A library implementing the Divo Stack behaviour, providing a pre-configured Postgres
database via docker-compose for integration testing Elixir apps. The database is a
single-node postgres compose stack that can be configured with an arbitrary
database and user to create on first start.

Requires inclusion of the Divo library in your mix project.

## Installation

The package can be installed by adding `divo` and `divo_postgres` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:divo, "~> 1.1"},
    {:divo_postgres, "~> 0.1.1"}
  ]
end
```

## Use

In your Mix environment exs file (i.e. config/integration.exs), include the following:
```elixir
config :myapp,
  divo: [
    {DivoPostgres, [user: "bob", database: "bobs_stuff", config_opts: ["shared_buffers=256MB", "max_connections=200"]]}
  ]
```

In your integration test specify that you want to use Divo:
```elixir
use Divo
...
```

The resulting stack will create a single-node Postgres database instance exposing
port 5432 to the host.

### Configuration

You may omit the configuration arguments to DivoPostgres and still have a working stack. The bare
minimum configuration of a user, password, database, and version of postgres all provide default values.

* `config_opts`: Provide configuration options to the database engine itself (such as max number of
connections). You may supply a single string value or a list of string values. When supplying the config
values, omit the `-c` flag that you would supply when directly starting the database process from the command
line. No default value is provided.

* `database`: The default database created by the init entrypoint script provided by Postgres. If further
databases are required, you may supply them via the `init_scripts` option. Defaults to `postgres`.

* `password`: The password applied to the default root user created by Postgres at boot. If further users and
passwords are required, you may supply them via the `init_scripts` option. Defaults to `postgres`.

* `init_scripts`: The path to additional setup scripts for intializing your database at boot. Create any
databases, users, pre-load values into tables, etc. Supply the scripts as a single string representing the path
to the script file or a list of paths. Ensure that the extension of your script files is `.sh` or `.sql`.
Postgres will run any executable shell script and source any that are not executable. No default is provided.

* `initdb_args`: Arguments passed to the `initdb` program that runs at first boot of the database and creates
the default database, user, and permissions for the root user. Supply as a single string or a list of strings
representing the arguments you might pass directly to `initdb` when executing it on the command line. No default is provided.

* `user`: The default root-level user with full administrative permissions on the system. If further users are
required, you may supply them via the `init_scripts` option. Defaults to `postgres`.

* `version`: The version of the postgres image, and thus the postgres database that will create the container.
Defaults to `latest`.

See [Divo GitHub](https://github.com/smartcitiesdata/divo) or [Divo Hex Documentation](https://hexdocs.pm/divo) for more instructions on using and configuring the Divo library.
See [Postgres Dockerhub](https://hub.docker.com/_/postgres) for further documentation
on using and configuring the features of the container image itself.
See [Postgres source](https://www.postgresql.org/) for the full codebase behind PostgreSQL


## License
Released under [Apache 2 license](https://github.com/jeffgrunewald/divo_postgres/blob/master/LICENSE).

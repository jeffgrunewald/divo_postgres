defmodule DivoPostgresTest do
  use ExUnit.Case

  describe "produces a postgres stack map" do
    test "in the default configuration" do
      expected = %{
        postgres: %{
          image: "postgres:latest",
          environment: [
            "POSTGRES_DB=postgres",
            "POSTGRES_PASSWORD=postgres",
            "POSTGRES_USER=postgres"
          ],
          healthcheck: %{
            test: ["CMD-SHELL", "pg_isready"],
            interval: "10s",
            timeout: "5s",
            retries: 5
          },
          ports: ["5432:5432"]
        }
      }

      actual = DivoPostgres.gen_stack([])

      assert expected == actual
    end

    test "with custom user and database values" do
      expected = [
            "POSTGRES_DB=bobs_stuff",
            "POSTGRES_PASSWORD=ssshhhhhh",
            "POSTGRES_USER=bob"
          ]

      args = [
        user: "bob",
        password: "ssshhhhhh",
        database: "bobs_stuff"
      ]
      actual = DivoPostgres.gen_stack(args)

      assert expected == actual.postgres.environment
    end

    test "with a custom run command to configure the database engine" do
      expected = [
        "postgres",
        "-c arg1",
        "-c arg2"
      ]

      actual = DivoPostgres.gen_stack([config_opts: ["arg1", "arg2"]])
      assert expected == actual.postgres.command
    end

    test "with additional init scripts mounted" do
      expected = [
        "test/support/init_scripts/script1.sql:/docker-entrypoint-initdb.d/script1.sql",
        "test/support/init_scripts/script2.sh:/docker-entrypoint-initdb.d/script2.sh"
      ]

      actual = DivoPostgres.gen_stack([init_scripts: ["test/support/init_scripts/script1.sql", "test/support/init_scripts/script2.sh"]])

      assert expected == actual.postgres.volumes
    end

    test "with initdb args merged into default environment variables" do
      expected = [
        "POSTGRES_INITDB_ARGS=--data-checksums",
        "POSTGRES_DB=bobs_stuff",
        "POSTGRES_PASSWORD=ssshhhhhh",
        "POSTGRES_USER=bob"
      ]

      args = [
        user: "bob",
        database: "bobs_stuff",
        password: "ssshhhhhh",
        initdb_args: [
          "--data-checksums"
        ]
      ]
      actual = DivoPostgres.gen_stack(args)

      assert expected == actual.postgres.environment
    end
  end
end

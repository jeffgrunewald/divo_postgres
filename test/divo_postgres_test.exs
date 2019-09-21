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

      assert actual == expected
    end
  end
end

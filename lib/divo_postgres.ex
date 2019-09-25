defmodule DivoPostgres do
  @moduledoc """
  Defines a single-node postgres database server
  as a map compatible with divo for building a
  docker-compose file.
  """
  @behaviour Divo.Stack

  @doc """
  Implements the Divo Stack behaviour to take a
  keyword list of defined variables specific to
  the DivoPostgres stack and returns a map describing
  the service definition of postgres.
  """
  @impl Divo.Stack
  @spec gen_stack([tuple()]) :: map()
  def gen_stack(envars) do
    config_opts = Keyword.get(envars, :config_opts)
    init_script_path = Keyword.get(envars, :init_scripts)
    initdb_args = Keyword.get(envars, :initdb_args)

    envars
    |> base_compose()
    |> add_config_opts(config_opts)
    |> add_init_scripts(init_script_path)
    |> add_initdb_args(initdb_args)
  end

  defp base_compose(envars) do
    database = Keyword.get(envars, :database, "postgres")
    password = Keyword.get(envars, :password, "postgres")
    user = Keyword.get(envars, :user, "postgres")
    version = Keyword.get(envars, :version, "latest")

    %{
      postgres: %{
        image: "postgres:#{version}",
        ports: ["5432:5432"],
        environment: [
          "POSTGRES_PASSWORD=#{password}",
          "POSTGRES_USER=#{user}",
          "POSTGRES_DB=#{database}"
        ],
        healthcheck: %{
          test: ["CMD-SHELL", "pg_isready --username=#{user} --dbname=#{database}"],
          interval: "10s",
          timeout: "5s",
          retries: 5
        }
      }
    }
  end

  defp add_config_opts(stack_map, opts) do
    case opts do
      nil -> stack_map
      _ -> %{stack_map | postgres: Map.put(stack_map.postgres, :command, build_command(opts))}
    end
  end

  defp build_command(opts) when is_list(opts) do
    ["postgres" | Enum.map(opts, fn arg -> "-c #{arg}" end)]
  end

  defp build_command(opt), do: ["postgres", "-c #{opt}"]

  defp add_init_scripts(stack_map, paths) do
    case paths do
      nil ->
        stack_map

      _ ->
        %{stack_map | postgres: Map.put(stack_map.postgres, :volumes, build_script_mounts(paths))}
    end
  end

  defp build_script_mounts(paths) when is_list(paths) do
    Enum.map(paths, &split_script_path/1)
  end

  defp build_script_mounts(path) do
    [split_script_path(path)]
  end

  defp split_script_path(path) do
    file =
      path
      |> String.split("/")
      |> List.last()

    "#{path}:/docker-entrypoint-initdb.d/#{file}"
  end

  defp add_initdb_args(stack_map, args) do
    case args do
      nil ->
        stack_map

      _ ->
        %{
          stack_map
          | postgres: %{
              stack_map.postgres
              | environment: [build_initdb_args(args) | stack_map.postgres.environment]
            }
        }
    end
  end

  defp build_initdb_args(args) when is_list(args),
    do: "POSTGRES_INITDB_ARGS=#{Enum.join(args, " ")}"

  defp build_initdb_args(arg), do: "POSTGRES_INITDB_ARGS=#{arg}"
end

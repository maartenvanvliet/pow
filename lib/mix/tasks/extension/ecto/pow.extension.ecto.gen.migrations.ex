defmodule Mix.Tasks.Pow.Extension.Ecto.Gen.Migrations do
  @shortdoc "Generates user extension migration files"

  @moduledoc """
  Generates a migration files for extensions.

  ## Usage

  Install migration files for extensions explicitly:

      mix pow.extension.ecto.gen.migrations -r MyApp.Repo --extension PowEmailConfirmation

      mix pow.extension.ecto.gen.migrations -r MyApp.Repo Accounts.Organization organizations --extension PowEmailConfirmation

  Use the context app configuration environment for extensions:

      mix pow.extension.ecto.gen.migrations -r MyApp.Repo

      mix pow.extension.ecto.gen.migrations -r MyApp.Repo Accounts.Organization organizations
  """
  use Mix.Task

  alias Pow.Extension.Ecto.Schema.Migration, as: SchemaMigration
  alias Mix.{Ecto, Pow, Pow.Ecto.Migration, Pow.Extension}

  @switches [binary_id: :boolean, extension: :keep]
  @default_opts [binary_id: false]

  @doc false
  def run(args) do
    Pow.no_umbrella!("pow.extension.ecto.gen.migrations")

    args
    |> Pow.parse_options(@switches, @default_opts)
    |> parse()
    |> create_migrations_files(args)
    |> print_shell_instructions()
  end

  defp parse({config, parsed, _invalid}) do
    case parsed do
      [_schema_name, schema_plural | _rest] ->
        Map.merge(config, %{schema_plural: schema_plural})

      _ ->
        config
    end
  end

  defp create_migrations_files(config, args) do
    context_base = Pow.context_base(Pow.context_app())
    otp_app      = String.to_atom(Macro.underscore(context_base))
    extensions   = Extension.extensions(config, otp_app)

    args
    |> Ecto.parse_repo()
    |> Enum.map(&Ecto.ensure_repo(&1, args))
    |> Enum.map(&Map.put(config, :repo, &1))
    |> Enum.each(&create_extension_migration_files(&1, extensions, context_base))

    %{extensions: extensions, otp_app: otp_app}
  end

  defp create_extension_migration_files(config, extensions, context_base) do
    for extension <- extensions,
      do: create_migration_files(config, extension, context_base)
  end

  defp create_migration_files(%{repo: repo, binary_id: binary_id} = config, extension, context_base) do
    schema_plural = Map.get(config, :schema_plural, "users")
    schema        = SchemaMigration.new(extension, context_base, schema_plural, repo: repo, binary_id: binary_id)
    content       = SchemaMigration.gen(schema)

    case empty?(schema) do
      true  -> nil
      false -> Migration.create_migration_files(repo, schema.migration_name, content)
    end
  end

  defp empty?(%{assocs: [], attrs: [], indexes: []}),
    do: true
  defp empty?(_schema), do: false

  defp print_shell_instructions(%{extensions: [], otp_app: otp_app}) do
    Extension.no_extensions_error(otp_app)
  end
  defp print_shell_instructions(config), do: config
end

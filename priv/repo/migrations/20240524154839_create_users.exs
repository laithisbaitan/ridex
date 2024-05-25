defmodule Ridex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :type, :string
      add :phone, :string

      timestamps(type: :utc_datetime)
    end
  end
end

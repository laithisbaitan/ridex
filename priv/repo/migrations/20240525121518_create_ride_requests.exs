defmodule Ridex.Repo.Migrations.CreateRideRequests do
  use Ecto.Migration

  def change do
    create table(:ride_requests) do
      add :lat, :float
      add :lng, :float
      add :rider_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:ride_requests, [:rider_id])
  end
end

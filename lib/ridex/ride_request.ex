defmodule Ridex.RideRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ride_requests" do
    field :lat, :float
    field :lng, :float
    field :rider_id, :id

    field :position, :map, virtual: true

    timestamps(type: :utc_datetime)
  end

  def create(rider, %{"lat" => lat, "lng" => lng}) do
    %Ridex.RideRequest{
      rider_id: rider.id,
      lat: lat,
      lng: lng
    }
    |> Ridex.Repo.insert()
  end

  @doc false
  def changeset(ride_request, attrs) do
    ride_request
    |> cast(attrs, [:lat, :lng])
    |> validate_required([:lat, :lng])
  end

  def get_position(%Ridex.RideRequest{lat: lat, lng: lng}) do
    %{"lat" => lat, "lng" => lng}
  end

  # Fetch the ride request and add the position map
  def get_with_position(id) do
    ride_request = Ridex.Repo.get(Ridex.RideRequest, id)
    %{
      ride_request
      | position: get_position(ride_request)
    }
  end
end

defmodule RidexWeb.CellChannel do
  alias Ridex.RideRequest
  use RidexWeb, :channel

  intercept ["ride:requested"]

  @impl true
  def join("cell:" <> _geohash, _payload, socket) do
    {:ok, %{}, socket}
    # if authorized?(payload) do
    #   {:ok, socket}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end

  @impl true
  def handle_in("ride:request", %{
    "position" => position
  }, socket) do
    case Ridex.RideRequest.create(socket.assigns[:current_user], position) do
      {:ok, request} ->
        broadcast! socket, "ride:requested", %{
          request_id: request.id,
          position: position
        }
        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, {:error, :insert_error}, socket}
    end
  end

  @impl true
  def handle_in("ride:accept_request", %{"request_id" => request_id}, socket) do
    case Ridex.Repo.get(Ridex.RideRequest, request_id) do
      nil ->
        {:reply, :error, socket}
      request ->
        case Ridex.Ride.create(request.rider_id, socket.assigns[:current_user].id, RideRequest.get_position(request)) do
          {:ok, ride} ->
            RidexWeb.Endpoint.broadcast("user:#{ride.driver_id}", "ride:created", %{ride_id: ride.id})
            RidexWeb.Endpoint.broadcast("user:#{ride.rider_id}", "ride:created", %{ride_id: ride.id})
            {:reply, :ok, socket}
          {:error, _changeset} ->
            {:reply, :error, socket}
        end
    end
  end

  @impl true
  def handle_out("ride:requested", payload, socket) do
    if socket.assigns[:current_user].type == "driver" do
      push(socket, "ride:requested", payload)
    end

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end

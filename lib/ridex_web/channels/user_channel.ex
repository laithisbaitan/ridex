defmodule RidexWeb.UserChannel do
  use RidexWeb, :channel
  alias RidexWeb.Presence

  def join("user:" <> user_id, _params, socket) do
    %{id: id} = socket.assigns[:current_user]

    if to_string(id) == user_id,
      do: {:ok, socket},
      else: {:error, :unauthorized}
  end

  def handle_in("update_position", %{"lat" => lat, "lng" => lng}, socket) do
    user = socket.assigns[:current_user]
    Presence.update(socket, user.id, %{
      lat: lat,
      lng: lng
    })

    {:noreply, socket}
  end
end

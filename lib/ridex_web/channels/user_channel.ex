defmodule RidexWeb.UserChannel do
  use RidexWeb, :channel

  def join("user:" <> user_id, _params, socket) do
    %{id: id} = socket.assigns[:current_user]

    if to_string(id) == user_id,
      do: {:ok, socket},
      else: {:error, :unauthorized}
  end
end

defmodule TcCache.Circle.Source.Builds do
  def process(%{status_code: 200, body: body}) do
    builds =
      body
      |> Poison.decode!()

    {:ok, builds}
  end

  def process(_), do: {:error, :server_not_happy}
end

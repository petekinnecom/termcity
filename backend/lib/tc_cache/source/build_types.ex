defmodule TcCache.Source.BuildTypes do
  def process(%{status_code: 200, body: body}) do
    build_types =
      body
      |> Poison.decode!()
      |> get_in(["buildType"])
      |> List.wrap()

    {:ok, build_types}
  end

  def process(_), do: {:error, :server_not_happy}
end

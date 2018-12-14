defmodule TcCache.Source.Teamcity.Authentication do
  def process(%{status_code: 200, body: body}) do
    is_member = body |> Poison.decode!() |> org_member?(authorized_org())

    case is_member do
      true -> {:ok, true}
      _ -> {:error, :not_member}
    end
  end

  def process(_args) do
    {:error, :token_failure}
  end

  defp org_member?([%{"login" => org} | _], org), do: true
  defp org_member?([_ | tail], org), do: org_member?(tail, org)
  defp org_member?([], _), do: false

  defp authorized_org do
    Application.get_env(:tc_cache, TcCache.Source)[:github_org]
  end
end

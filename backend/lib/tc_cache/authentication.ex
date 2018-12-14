defmodule TcCache.Authentication do
  @github_org_path "https://api.github.com/user/orgs"

  def authenticate(token, get) do
    if cached?(token) do
      {:ok, true}
    else
      case do_authenticate(token, get) do
        {:ok, _} -> {:ok, Cachex.put!(:tc, token, true)}
        {:error, msg} -> {:error, msg}
      end
    end
  end

  defp cached?(token) do
    {:ok, val} = Cachex.exists?(:tc, token)
    val
  end

  defp do_authenticate(token, get) do
    get.(
      @github_org_path,
      [
        {"Accept", "application/json"},
        {"Authorization", "token #{token}"}
      ],
      []
    )
    |> process()
  end

  defp process(%{status_code: 200, body: body}) do
    is_member = body |> Poison.decode!() |> org_member?(authorized_org())

    case is_member do
      true -> {:ok, true}
      _ -> {:error, :not_member}
    end
  end

  defp process(_args) do
    {:error, :token_failure}
  end

  defp org_member?([%{"login" => org} | _], org), do: true
  defp org_member?([_ | tail], org), do: org_member?(tail, org)
  defp org_member?([], _), do: false

  defp authorized_org do
    Application.get_env(:tc_cache, TcCache.Authentication)[:github_org]
  end
end

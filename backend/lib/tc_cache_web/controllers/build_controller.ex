defmodule TcCacheWeb.BuildController do
  use TcCacheWeb, :controller
  require Logger

  def index(conn, params = %{"project_id" => project_id, "branch" => branch, "reponame" => reponame}, api) do
    auth_header = Plug.Conn.get_req_header(conn, "authorization")

    case auth_header do
      [] ->
        Logger.info("Access Denied: no token")
        send_resp(conn, 403, "authorization token required")

      [token] ->
        auth_task = Task.async(fn -> api.authenticate(token) end)

        build_info_task =
          Task.async(fn ->
            api.build_info(project_id, reponame, branch, params["revision"])
          end)

        case Task.await(auth_task) do
          {:ok, _} ->
            Logger.info("Valid token. Returning info for #{project_id}, #{branch}")
            json(conn, Task.await(build_info_task))

          _ ->
            Logger.info("Access Denied: invalid token")
            send_resp(conn, 401, "Not allowed")
        end
    end
  end

  def health(conn, _, _), do: send_resp(conn, 200, "ok")

  def action(conn, _opts) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, TcCache.Api])
  end
end

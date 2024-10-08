defmodule BackendBattle.AppRouter do
  use Plug.Router

  alias BackendBattle.AppRepo
  alias BackendBattle.Message

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/pessoas" do
    conn = fetch_query_params(conn)

    case conn.params["t"] do
      nil ->
        send_resp(conn, 400, [])

      "" ->
        send_resp(conn, 400, [])

      term ->
        case AppRepo.find_by_term(term) do
          {:ok, rows} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Jason.encode!(rows))

          {:not_found, _} ->
            send_resp(conn, 404, [])
        end
    end
  end

  get "/pessoas/:id" do
    id = conn.params["id"]

    case AppRepo.get_by_id(id) do
      {:not_found, _} ->
        send_resp(conn, 404, [])

      {:ok, obj} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(obj))
    end
  end

  post "/pessoas" do
    case conn.body_params do
      %{"apelido" => _, "nome" => _, "nascimento" => _} = payload ->
        case handle_post(payload) do
          {:ok, id} ->
            conn
            |> put_resp_content_type("application/json")
            |> put_resp_header("Location", "/pessoas/#{id}")
            |> send_resp(201, [])

          :unprocessable ->
            send_resp(conn, 422, [])

          _ ->
            send_resp(conn, 400, [])
        end

      _ ->
        conn
        |> send_resp(400, Jason.encode!(%{error: "Invalid request"}))
    end
  end

  defp handle_post(%{"apelido" => nick} = payload) do
    case Message.valid_payload?(payload) do
      :ok ->
        id = UUID.uuid5(:oid, nick)

        case AppRepo.member?(id, payload) do
          :found -> :unprocessable
          :new -> {:ok, id}
        end

      err ->
        err
    end
  end

  get "/contagem-pessoas" do
    total = AppRepo.info() |> Enum.count() |> to_string()
    send_resp(conn, 200, total)
  end

  # Default route for non-matching paths
  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end

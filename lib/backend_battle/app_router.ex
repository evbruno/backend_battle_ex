defmodule BackendBattle.AppRouter do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/pessoas" do
    conn = fetch_query_params(conn)
    term = conn.params["t"]

    found = [
      %{id: UUID.uuid5(:oid, "Foo-#{term}"), apelido: "Foo#{term}"},
      %{id: UUID.uuid5(:oid, "Bar-#{term}"), apelido: "Bar#{term}"}
    ]

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(found))
  end

  get "/pessoas/:id" do
    id = conn.params["id"]

    case BackendBattle.AppRepo.get_by_id(id) do
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
    case BackendBattle.Message.valid_payload?(payload) do
      :ok ->
        id = UUID.uuid5(:oid, nick)

        case BackendBattle.AppRepo.member?(id, payload) do
          :found -> :unprocessable
          :new -> {:ok, id}
        end

      err ->
        err
    end
  end


  get "/contagem-pessoas" do
    total = BackendBattle.AppRepo.info() |> Enum.count |> to_string()
    send_resp(conn, 200, total)
  end

  # Default route for non-matching paths
  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end

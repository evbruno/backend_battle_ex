
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
      %{ id: UUID.uuid5(:oid, "Foo-#{term}"), apelido: "Foo#{term}" },
      %{ id: UUID.uuid5(:oid, "Bar-#{term}"), apelido: "Bar#{term}" }
    ]

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(found))
  end

  get "/pessoas/:id" do
    id = conn.params["id"]
    nick = "Foo"

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{id: id, apelido: nick}))
  end

  post "/pessoas" do
    case conn.body_params do
      %{"apelido" => nick} ->

        id = UUID.uuid5(:oid, nick)

        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("Location", "/pessoas/#{id}")
        |> send_resp(201, [])

      _ ->
        conn
        |> send_resp(400, Jason.encode!(%{error: "Invalid request"}))
    end
  end

  get "/contagem-pessoas" do
    send_resp(conn, 200, "42")
  end

  # Default route for non-matching paths
  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end

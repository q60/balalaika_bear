defmodule BalalaikaBear.Longpoll.GroupLongpoll do
  def init(parent, data) do
    result = get_server(data)
    %{"server" => server, "key" => key, "ts" => ts} = result
    response = connect(server, key, ts)
    send(parent, {:ok, response})

    process(
      response,
      result,
      ts,
      parent,
      data
    )
  end

  defp get_server(%{access_token: token, group_id: id, v: version}) do
    server =
      BalalaikaBear.Groups.get_long_poll_server(%{
        group_id: id,
        access_token: token,
        v: version
      })

    case server do
      {:ok, result} ->
        result

      _ ->
        get_server(%{access_token: token, group_id: id, v: version})
    end
  end

  defp connect(server, key, ts) do
    response =
      HTTPoison.post(
        server,
        URI.encode_query(%{act: "a_check", key: key, ts: ts, wait: 25})
      )

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)

      _ ->
        connect(server, key, ts)
    end
  end

  defp process(response, result, ts, parent, data) do
    [response, result, ts] =
      case response["failed"] do
        1 ->
          server = result["server"]
          key = result["key"]
          ts = response["ts"]
          response = connect(server, key, ts)
          send(parent, {:err, 1})
          [response, result, ts]

        2 ->
          result = get_server(data)
          %{"server" => server, "key" => key, "ts" => _} = result
          response = connect(server, key, ts)
          [response, result, ts]

        3 ->
          result = get_server(data)
          %{"server" => server, "key" => key, "ts" => ts} = result
          response = connect(server, key, ts)
          [response, result, ts]

        _ ->
          server = result["server"]
          key = result["key"]
          ts = response["ts"]
          response = connect(server, key, ts)
          send(parent, {:ok, response})
          [response, result, ts]
      end

    process(response, result, ts, parent, data)
  end
end

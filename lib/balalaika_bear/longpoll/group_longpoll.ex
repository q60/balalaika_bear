defmodule BalalaikaBear.Longpoll.GroupLongpoll do
  def init(parent, %{group_id: id, access_token: token, v: version}) do
    result = get_server(%{group_id: id, access_token: token, v: version})
    response = connect(result["server"], result["key"], result["ts"])
    send(parent, {:ok, response})

    process(
      response,
      result,
      parent,
      %{group_id: id, access_token: token, v: version}
    )
  end

  defp get_server(%{group_id: id, access_token: token, v: version}) do
    {:ok, result} =
      BalalaikaBear.Groups.get_long_poll_server(%{
        group_id: id,
        access_token: token,
        v: version
      })

    result
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

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        connect(server, key, ts)
    end
  end

  defp process(response, result, parent, data) do
    response =
      case response["failed"] do
        1 ->
          connect(result["server"], result["key"], response["ts"])

        2 ->
          result = get_server(data)
          connect(result["server"], result["key"], response["ts"])

        3 ->
          result = get_server(data)
          connect(result["server"], result["key"], result["ts"])

        _ ->
          connect(result["server"], result["key"], response["ts"])
      end

    send(parent, {:ok, response})
    process(response, result, parent, data)
  end
end

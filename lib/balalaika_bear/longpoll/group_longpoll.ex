defmodule BalalaikaBear.Longpoll.GroupLongpoll do
  def init_longpoll(parent, %{group_id: id, access_token: token, v: version}) do
    result = get_server(%{group_id: id, access_token: token, v: version})
    response = connect_longpoll(result["server"], result["key"], result["ts"])
    send(parent, {:ok, response})
    process_longpoll(response, result, parent, %{group_id: id, access_token: token, v: version})
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

  defp connect_longpoll(server, key, ts) do
    response =
      HTTPoison.post(
        server,
        URI.encode_query(%{act: "a_check", key: key, ts: ts, wait: 25})
      )

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        connect_longpoll(server, key, ts)
    end
  end

  defp process_longpoll(response, result, parent, data) do
    response =
      case response["failed"] do
        1 ->
          connect_longpoll(result["server"], result["key"], response["ts"])

        2 ->
          result = get_server(data)
          connect_longpoll(result["server"], result["key"], response["ts"])

        3 ->
          result = get_server(data)
          connect_longpoll(result["server"], result["key"], result["ts"])

        _ ->
          connect_longpoll(result["server"], result["key"], response["ts"])
      end

    send(parent, {:ok, response})
    process_longpoll(response, result, parent, data)
  end
end

defmodule BalalaikaBear.Request.HTTPClient do
  require Logger

  alias BalalaikaBear.Request.Params
  @base_url "https://api.vk.com/method/"
  @vk_api_version "5.103"

  def request_with_params(method, params, headers \\ %{}, body \\ []) do
    url = request_url(method, params)
    request(:get, url, headers, body)
  end

  def request(type, url, headers \\ %{}, body \\ [], options \\ []) do
    case HTTPoison.request(type, url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: code, body: body, headers: headers}} ->
        %{status_code: code, body: body, headers: headers} |> response

      {:error, %HTTPoison.Error{id: _, reason: reason}} ->
        Logger.error("BalalaikaBear.Request.HTTPClient error: #{reason}")
    end
  end

  defp request_url(method, params) do
    @base_url <> "#{method}?v=#{@vk_api_version}&" <> Params.url_params(params)
  end

  defp response(%{status_code: code, body: body, headers: _}) do
    case code do
      200 -> parse_result(body)
      _ -> {:error, Jason.decode!(body)}
    end
  end

  defp parse_result(body) do
    body = Jason.decode!(body)

    case body do
      %{"response" => response_map} ->
        {:ok, response_map}

      %{"error" => error_map} ->
        {:error, error_map}

      _ ->
        {:ok, body}
    end
  end
end

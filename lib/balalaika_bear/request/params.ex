defmodule BalalaikaBear.Request.Params do
  @moduledoc false

  def url_params(params, default_params \\ %{}) do
    params
    |> Map.merge(default_params)
    |> Enum.reduce([], fn {key, value}, acc ->
      ["#{key}=#{encode_params(value)}" | acc]
    end)
    |> Enum.join("&")
  end

  defp encode_params(values) when is_list(values) do
    values
    |> Enum.join(",")
    |> String.replace(" ", "%20")
    |> String.replace("\n", "%0A")
  end

  defp encode_params(value) when is_binary(value) do
    value
    |> String.replace(" ", "%20")
    |> String.replace("\n", "%0A")
  end

  defp encode_params(value) do
    value
  end
end

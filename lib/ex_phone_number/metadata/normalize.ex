defmodule ExPhoneNumber.Metadata.Normalize do
  def pattern(nil), do: nil
  def pattern([]), do: nil
  def pattern(""), do: nil

  def pattern(pattern) when is_binary(pattern) do
    pattern
    |> String.replace(["\n", " "], "")
    |> Regex.compile!()
  end

  def string(""), do: nil
  def string(string) when is_binary(string), do: string

  def boolean("true"), do: true
  def boolean(_), do: false

  def rule(nil), do: nil

  def rule(char_list) when is_list(char_list),
    do: char_list |> List.to_string() |> rule()

  def rule(string) when is_binary(string) do
    string
    |> String.replace(~r/\$(\d)/, "\\\\g{\\g{1}}")
  end

  def range(""), do: nil

  def range(string) when is_binary(string) do
    string
    |> String.replace(["\n", " "], "")
    |> String.split(",")
    |> Enum.flat_map(&range_to_list/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp range_to_list("[" <> range) do
    range
    |> String.trim_trailing("]")
    |> String.split("-", parts: 2)
    |> then(fn [from, to] -> Range.new(String.to_integer(from), String.to_integer(to)) end)
    |> Enum.to_list()
  end

  defp range_to_list(number) do
    [String.to_integer(number)]
  end
end

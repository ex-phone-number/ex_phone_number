defmodule ExPhoneNumber.Metadata.PhoneNumberDescription do
  defstruct national_number_pattern: nil, # string
            possible_lengths: nil,        # list
            example_number: nil           # string

  import SweetXml
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def from_xpath_node(nil), do: nil
  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node
      |> xmap(
           national_number_pattern: ~x"./nationalNumberPattern/text()"o |> transform_by(&normalize_pattern/1),
           national_possible_lengths: ~x"./possibleLengths/@national"o |> transform_by(&normalize_range/1),
           local_possible_lengths: ~x"./possibleLengths/@localOnly"o |> transform_by(&normalize_range/1),
           example_number: ~x"./exampleNumber/text()"o |> transform_by(&normalize_string/1)
         )

    possible_lengths =
      (kwlist.local_possible_lengths || [])
      |> Enum.concat(kwlist.national_possible_lengths || [])
      |> Enum.sort
      |> Enum.dedup()

    struct(%PhoneNumberDescription{}, %{
      national_number_pattern: kwlist.national_number_pattern,
      possible_lengths: possible_lengths,
      example_number: kwlist.example_number
    })
  end

  defp clean_list(char_list) do
    char_list
    |> List.to_string
    |> String.split(["\n", " "], trim: true)
    |> List.to_string
  end

  defp normalize_string(nil), do: nil
  defp normalize_string(char_list) when is_list(char_list), do: clean_list(char_list)

  defp normalize_pattern(nil), do: nil
  defp normalize_pattern(char_list) when is_list(char_list) do
    char_list
    |> clean_list
    |> Regex.compile!()
  end

  defp normalize_range(nil), do: nil
  defp normalize_range(char_list) when is_list(char_list) do
    char_list
    |> clean_list
    |> String.split(",")
    |> Enum.map(&range_to_list/1)
    |> List.flatten
    |> Enum.sort
    |> Enum.dedup
  end

  defp range_to_list(range_or_number) do
    case String.first(range_or_number) do
      "[" ->
        [range_start, range_end] =
          String.slice(range_or_number, 1, String.length(range_or_number) - 2)
          |> String.split("-")
          |> Enum.map(fn n -> String.to_integer(n) end)

        Range.new(range_start, range_end)
        |> Enum.to_list
      _ -> String.to_integer(range_or_number)
    end
  end
end

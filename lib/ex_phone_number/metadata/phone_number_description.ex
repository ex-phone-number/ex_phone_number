defmodule ExPhoneNumber.Metadata.PhoneNumberDescription do
  # string
  defstruct national_number_pattern: nil,
            # list
            possible_lengths: nil,
            # string
            example_number: nil

  import SweetXml
  alias ExPhoneNumber.Utilities
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def from_xpath_node(nil), do: nil

  def from_xpath_node(xpath_node) do
    kwlist =
      xmap(
        xpath_node,
        national_number_pattern: ~x"./nationalNumberPattern/text()"o |> transform_by(&normalize_pattern/1),
        national_possible_lengths: ~x"./possibleLengths/@national"o |> transform_by(&normalize_range/1),
        local_possible_lengths: ~x"./possibleLengths/@localOnly"o |> transform_by(&normalize_range/1),
        example_number: ~x"./exampleNumber/text()"o |> transform_by(&normalize_string/1)
      )

    possible_lengths =
      (kwlist.local_possible_lengths || [])
      |> Enum.concat(kwlist.national_possible_lengths || [])
      |> Enum.sort()
      |> Enum.uniq()

    struct(%PhoneNumberDescription{}, %{
      national_number_pattern: kwlist.national_number_pattern,
      possible_lengths: possible_lengths,
      example_number: kwlist.example_number
    })
  end

  defp clean_string(string) when is_binary(string) do
    string
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
  end

  defp normalize_string(nil), do: nil

  defp normalize_string(char_list) when is_list(char_list),
    do: List.to_string(char_list) |> clean_string

  defp normalize_pattern(nil), do: nil

  defp normalize_pattern(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
    |> clean_string
    |> Regex.compile!()
  end

  defp normalize_range(nil), do: nil

  defp normalize_range(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
    |> clean_string
    |> String.split(",")
    |> Enum.map(&range_to_list/1)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp range_to_list(range_or_number) do
    case String.first(range_or_number) do
      "[" ->
        [range_start, range_end] =
          String.slice(range_or_number, 1, String.length(range_or_number) - 2)
          |> String.split("-")
          |> Enum.map(fn n -> String.to_integer(n) end)

        Range.new(range_start, range_end)
        |> Enum.to_list()

      _ ->
        String.to_integer(range_or_number)
    end
  end

  @spec has_data?(%PhoneNumberDescription{}) :: boolean()
  def has_data?(%PhoneNumberDescription{
        example_number: example_number
      })
      when is_binary(example_number) do
    true
  end

  def has_data?(%PhoneNumberDescription{
        national_number_pattern: %Regex{} = _national_number_pattern
      }) do
    true
  end

  def has_data?(%PhoneNumberDescription{
        possible_lengths: possible_lengths
      })
      when is_list(possible_lengths) do
    List.first(possible_lengths) > 0
  end

  def has_data?(%PhoneNumberDescription{}) do
    false
  end

  @spec has_example_number(%PhoneNumberDescription{}) :: boolean()
  def has_example_number(%PhoneNumberDescription{} = phone_number_description) do
    not Utilities.is_nil_or_empty?(phone_number_description.example_number)
  end
end

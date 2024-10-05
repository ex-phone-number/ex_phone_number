defmodule ExPhoneNumber.Metadata.PhoneNumberDescription do
  @moduledoc false
  import SweetXml

  alias ExPhoneNumber.Metadata.Normalize
  alias ExPhoneNumber.Metadata.PhoneNumberDescription
  # string
  defstruct national_number_pattern: nil,
            # list
            possible_lengths: nil,
            # string
            example_number: nil

  def from_xpath_node(nil), do: nil

  def from_xpath_node(xpath_node) do
    kwlist =
      xmap(
        xpath_node,
        national_number_pattern: transform_by(~x"./nationalNumberPattern/text()"so, &Normalize.pattern/1),
        national_possible_lengths: transform_by(~x"./possibleLengths/@national"so, &Normalize.range/1),
        local_possible_lengths: transform_by(~x"./possibleLengths/@localOnly"so, &Normalize.range/1),
        example_number: transform_by(~x"./exampleNumber/text()"so, &Normalize.string/1)
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
end

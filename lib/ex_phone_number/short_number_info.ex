defmodule ExPhoneNumber.ShortNumberInfo do
  @moduledoc """
  Functions for short numbers, such as SMS short codes and service numbers.

  Short numbers are not handled by `ExPhoneNumber.is_valid_number?/1`. They use their
  own metadata (`ShortNumberMetadata.xml` from libphonenumber) and are checked here.
  Ported from libphonenumber's `ShortNumberInfo`.

  Numbers can be built with `ExPhoneNumber.parse/2`:

      iex> {:ok, number} = ExPhoneNumber.parse("1010", "FR")
      iex> ExPhoneNumber.ShortNumberInfo.is_valid_short_number?(number)
      true
  """

  import SweetXml
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneNumberDescription
  alias ExPhoneNumber.Model.PhoneNumber
  alias ExPhoneNumber.Utilities

  @document_path Path.join("resources", "ShortNumberMetadata.xml")
  @external_resource @document_path

  territories =
    @document_path
    |> File.read!()
    |> xpath(
      ~x"//phoneNumberMetadata/territories/territory"el,
      id: ~x"./@id"s,
      general: ~x"./generalDesc"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
      short_code: ~x"./shortCode"eo |> transform_by(&PhoneNumberDescription.from_xpath_node/1)
    )

  # generalDesc carries no possibleLengths in the XML. Like libphonenumber's build step for
  # short number metadata, it takes the lengths of the shortCode description.
  @metadata Map.new(territories, fn territory ->
              general = %{territory.general | possible_lengths: territory.short_code.possible_lengths}
              {territory.id, %{general: general, short_code: territory.short_code}}
            end)

  @doc """
  Checks whether a short number is possible (has a possible length) in any region
  that uses its country calling code.

  More lenient than `is_valid_short_number?/1`.
  """
  @spec is_possible_short_number?(PhoneNumber.t()) :: boolean()
  def is_possible_short_number?(%PhoneNumber{} = number) do
    length = number |> PhoneNumber.get_national_significant_number() |> String.length()

    number.country_code
    |> region_codes()
    |> Enum.any?(fn region ->
      case @metadata[region] do
        nil -> false
        metadata -> length in metadata.general.possible_lengths
      end
    end)
  end

  @doc """
  Checks whether a short number is possible when dialed from `region_dialing_from`.
  """
  @spec is_possible_short_number?(PhoneNumber.t(), String.t() | nil) :: boolean()
  def is_possible_short_number?(%PhoneNumber{} = number, region_dialing_from) do
    with true <- is_binary(region_dialing_from),
         region_dialing_from = String.upcase(region_dialing_from),
         true <- region_dialing_from in region_codes(number.country_code),
         %{} = metadata <- @metadata[region_dialing_from] do
      length = number |> PhoneNumber.get_national_significant_number() |> String.length()
      length in metadata.general.possible_lengths
    else
      _ -> false
    end
  end

  @doc """
  Checks whether a short number matches a valid pattern in any region that uses its
  country calling code.

  This does not verify that the number is actually in use.
  """
  @spec is_valid_short_number?(PhoneNumber.t()) :: boolean()
  def is_valid_short_number?(%PhoneNumber{} = number) do
    number.country_code
    |> region_codes()
    |> Enum.any?(&is_valid_short_number?(number, &1))
  end

  @doc """
  Checks whether a short number matches a valid pattern when dialed from `region_dialing_from`.
  """
  @spec is_valid_short_number?(PhoneNumber.t(), String.t() | nil) :: boolean()
  def is_valid_short_number?(%PhoneNumber{} = number, region_dialing_from) do
    with true <- is_binary(region_dialing_from),
         region_dialing_from = String.upcase(region_dialing_from),
         true <- region_dialing_from in region_codes(number.country_code),
         %{} = metadata <- @metadata[region_dialing_from] do
      short_number = PhoneNumber.get_national_significant_number(number)
      matches?(short_number, metadata.general) and matches?(short_number, metadata.short_code)
    else
      _ -> false
    end
  end

  defp region_codes(country_code), do: Map.get(Metadata.country_code_to_region_code_map(), country_code, [])

  defp matches?(_number, nil), do: false

  defp matches?(number, %PhoneNumberDescription{} = description) do
    (description.possible_lengths == [] or String.length(number) in description.possible_lengths) and
      Utilities.matches_entirely?(description.national_number_pattern, number)
  end
end

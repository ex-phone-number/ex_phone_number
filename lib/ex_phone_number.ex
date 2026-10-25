defmodule ExPhoneNumber do
  @moduledoc """
  Parsing, formatting, and validating international phone numbers.

  ## Example Usage

      iex> ExPhoneNumber.parse("202-456-1111", "US")
      {
        :ok,
        %ExPhoneNumber.Model.PhoneNumber{
          country_code: 1,
          country_code_source: nil,
          extension: nil,
          italian_leading_zero: nil,
          national_number: 2024561111,
          number_of_leading_zeros: nil,
          preferred_domestic_carrier_code: nil,
          raw_input: nil
        }
      }

      iex> {:ok, phone_number} = ExPhoneNumber.parse("202-456-1111", "US")
      iex> ExPhoneNumber.format(phone_number, :e164)
      "+12024561111"
      iex> ExPhoneNumber.is_valid_number?(phone_number)
      true
      iex> ExPhoneNumber.is_possible_number?(phone_number)
      true
      iex> ExPhoneNumber.get_number_type(phone_number)
      :fixed_line_or_mobile
  """

  alias ExPhoneNumber.Formatting
  alias ExPhoneNumber.Parsing
  alias ExPhoneNumber.Validation
  alias ExPhoneNumber.Metadata

  @doc """
  Formats a parsed phone number.

  `phone_number_format` is one of `:e164`, `:international`, `:national` or `:rfc3966`.

      iex> {:ok, phone_number} = ExPhoneNumber.parse("202-456-1111", "US")
      iex> ExPhoneNumber.format(phone_number, :e164)
      "+12024561111"
  """
  def format(%ExPhoneNumber.Model.PhoneNumber{} = phone_number, phone_number_format)
      when is_atom(phone_number_format),
      do: Formatting.format(phone_number, phone_number_format)

  @doc """
  Returns the type of a parsed phone number, based on the metadata of its region.

  Possible types: `:fixed_line`, `:mobile`, `:fixed_line_or_mobile`, `:toll_free`,
  `:premium_rate`, `:shared_cost`, `:voip`, `:personal_number`, `:pager`, `:uan`,
  `:voicemail` and `:unknown`.

      iex> {:ok, phone_number} = ExPhoneNumber.parse("202-456-1111", "US")
      iex> ExPhoneNumber.get_number_type(phone_number)
      :fixed_line_or_mobile
  """
  def get_number_type(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: Validation.get_number_type(phone_number)

  @doc """
  Checks whether a parsed phone number is possible, looking only at its length.

  This is faster and more lenient than `is_valid_number?/1`.

      iex> {:ok, phone_number} = ExPhoneNumber.parse("202-456-1111", "US")
      iex> ExPhoneNumber.is_possible_number?(phone_number)
      true
  """
  def is_possible_number?(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: Validation.is_possible_number?(phone_number)

  @doc """
  Parses `number` as if dialed from `region_code` and checks whether it is a possible number.

      iex> ExPhoneNumber.is_possible_number?("202-456-1111", "US")
      true
  """
  def is_possible_number?(number, region_code) when is_binary(number),
    do: Parsing.is_possible_number?(number, region_code)

  @doc """
  Checks whether a parsed phone number matches a valid pattern for its region.

  This does not verify that the number is actually in use.

      iex> {:ok, phone_number} = ExPhoneNumber.parse("202-456-1111", "US")
      iex> ExPhoneNumber.is_valid_number?(phone_number)
      true
  """
  def is_valid_number?(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: Validation.is_valid_number?(phone_number)

  @doc """
  Parses a string into a phone number struct.

  `default_region` is a two-letter region code (e.g. `"US"`) used when the number
  is not written in international format. For numbers starting with `+`, it can be
  `""` or `nil`.

  Returns `{:ok, phone_number}` or `{:error, message}`.

      iex> {:ok, phone_number} = ExPhoneNumber.parse("+1 202-456-1111", nil)
      iex> phone_number.country_code
      1
      iex> phone_number.national_number
      2024561111
  """
  def parse(number_to_parse, default_region),
    do: Parsing.parse(number_to_parse, default_region)

  @doc """
  Returns a map of country codes to region codes.
  """
  defdelegate country_code_to_region_code_map(), to: Metadata
end

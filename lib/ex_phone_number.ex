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

  def format(%ExPhoneNumber.Model.PhoneNumber{} = phone_number, phone_number_format)
      when is_atom(phone_number_format),
      do: Formatting.format(phone_number, phone_number_format)

  def get_number_type(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: Validation.get_number_type(phone_number)

  def is_possible_number?(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: Validation.is_possible_number?(phone_number)

  def is_possible_number?(number, region_code) when is_binary(number),
    do: Parsing.is_possible_number?(number, region_code)

  def is_valid_number?(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: Validation.is_valid_number?(phone_number)

  def parse(number_to_parse, default_region),
    do: Parsing.parse(number_to_parse, default_region)
end

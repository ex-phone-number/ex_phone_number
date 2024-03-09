defmodule ExPhoneNumber do
  @moduledoc """
  Parsing, formatting, and validating international phone numbers.
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

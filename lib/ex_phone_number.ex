defmodule ExPhoneNumber do
  alias ExPhoneNumber.{
    Formatting,
    Parsing,
    Validation
  }

  def format(phone_number = %ExPhoneNumber.Model.PhoneNumber{}, phone_number_format) when is_atom(phone_number_format), do: Formatting.format(phone_number, phone_number_format)

  def get_number_type(phone_number = %ExPhoneNumber.Model.PhoneNumber{}), do: Validation.get_number_type(phone_number)

  def is_possible_number?(phone_number = %ExPhoneNumber.Model.PhoneNumber{}), do: Validation.is_possible_number?(phone_number)

  def is_possible_number?(number, region_code) when is_binary(number), do: Parsing.is_possible_number?(number, region_code)

  def is_valid_number?(phone_number = %ExPhoneNumber.Model.PhoneNumber{}), do: Validation.is_valid_number?(phone_number)

  def parse(number_to_parse, default_region), do: Parsing.parse(number_to_parse, default_region)
end

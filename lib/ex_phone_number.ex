defmodule ExPhoneNumber do
  def format(%ExPhoneNumber.Model.PhoneNumber{} = phone_number, phone_number_format)
      when is_atom(phone_number_format),
      do: ExPhoneNumber.Formatting.format(phone_number, phone_number_format)

  def get_number_type(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: ExPhoneNumber.Validation.get_number_type(phone_number)

  def is_possible_number?(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: ExPhoneNumber.Validation.is_possible_number?(phone_number)

  def is_possible_number?(number, region_code) when is_binary(number),
    do: ExPhoneNumber.Parsing.is_possible_number?(number, region_code)

  def is_valid_number?(%ExPhoneNumber.Model.PhoneNumber{} = phone_number),
    do: ExPhoneNumber.Validation.is_valid_number?(phone_number)

  def parse(number_to_parse, default_region), do: ExPhoneNumber.Parsing.parse(number_to_parse, default_region)
end

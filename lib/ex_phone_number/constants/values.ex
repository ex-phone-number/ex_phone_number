defmodule ExPhoneNumber.Constants.Values do
  def nanpa_country_code(), do: 1

  def min_length_for_nsn(), do: 2

  def max_length_for_nsn(), do: 17

  def max_length_country_code(), do: 3

  def max_input_string_length(), do: 250

  def unknown_region(), do: "ZZ"

  def colombia_mobile_to_fixed_line_prefix(), do: "3"

  def plus_sign(), do: "+"

  def star_sign(), do: "*"

  def rfc3966_extn_prefix(), do: ";ext="

  def rfc3966_prefix(), do: "tel:"

  def rfc3966_phone_context(), do: ";phone-context="

  def rfc3966_isdn_subaddress(), do: ";isub="

  def region_code_for_non_geo_entity(), do: "001"

  def description_default_pattern(), do: "NA"

  def description_default_length(), do: [-1]

  def default_extn_prefix(), do: " ext. "
end

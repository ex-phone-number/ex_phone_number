defmodule ExPhoneNumber.Constants.ErrorMessages do
  def invalid_country_code, do: "Invalid country calling code"

  def not_a_number, do: "The string supplied did not seem to be a phone number"

  def too_short_after_idd, do: "Phone number too short after IDD"

  def too_short_nsn, do: "The string supplied is too short to be a phone number"

  def too_long, do: "The string supplied is too long to be a phone number"
end

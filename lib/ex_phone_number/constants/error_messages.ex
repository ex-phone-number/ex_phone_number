defmodule ExPhoneNumber.Constants.ErrorMessages do
  @moduledoc false

  def invalid_country_code(), do: "Invalid country calling code"

  def not_a_number(), do: "The string supplied is not a valid phone number"

  def too_short_after_idd(), do: "The phone number is too short after IDD"

  def too_short_nsn(), do: "The string supplied is too short to be a phone number"

  def too_long(), do: "The string supplied is too long to be a phone number"
end

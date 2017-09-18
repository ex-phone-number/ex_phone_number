defmodule ExPhoneNumber.Constants.ValidationResults do
  def is_possible, do: :is_possible

  def invalid_country_code, do: :invalid_country_code

  def too_short, do: :too_short

  def too_long, do: :too_long
end

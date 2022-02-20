defmodule ExPhoneNumber.Constants.ValidationResults do
  @type t() :: :is_possible | :is_possible_local_only | :invalid_country_code | :too_short | :invalid_length | :too_long

  def is_possible(), do: :is_possible

  def is_possible_local_only(), do: :is_possible_local_only

  def invalid_country_code(), do: :invalid_country_code

  def too_short(), do: :too_short

  def invalid_length(), do: :invalid_length

  def too_long(), do: :too_long
end

defmodule ExPhoneNumber.Constants.MatchTypes do
  def not_a_number, do: :not_a_number

  def no_match, do: :no_match

  def short_nsn_match, do: :short_nsn_match

  def nsn_match, do: :nsn_match

  def exact_match, do: :exact_match
end

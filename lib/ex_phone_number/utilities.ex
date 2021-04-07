defmodule ExPhoneNumber.Utilities do
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def is_nil_or_empty?(nil), do: true
  def is_nil_or_empty?(""), do: true
  def is_nil_or_empty?([]), do: true
  def is_nil_or_empty?(_), do: false

  def is_number_matching_description?(number, %PhoneNumberDescription{} = description)
      when is_binary(number) do
    if description.possible_lengths == Values.description_default_length() or
         description.national_number_pattern == Values.description_default_pattern() do
      false
    else
      matches_entirely?(description.national_number_pattern, number)
    end
  end

  @doc """
  Check whether the entire input sequence can be matched against the regular
  expression.

  Implements `i18n.phonenumbers.PhoneNumberUtil.matchesEntirely`
  """
  @spec matches_entirely?(Regex.t() | nil, binary()) :: boolean()
  def matches_entirely?(nil, _string), do: false

  def matches_entirely?(regex, string) do
    regex = ~r/^(?:#{regex.source})$/

    case Regex.run(regex, string, return: :index) do
      [{_index, length} | _tail] -> Kernel.byte_size(string) == length
      _ -> false
    end
  end
end

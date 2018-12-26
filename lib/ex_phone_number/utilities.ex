defmodule ExPhoneNumber.Utilities do
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def is_nil_or_empty?(nil), do: true
  def is_nil_or_empty?(string) when is_binary(string), do: String.length(string) == 0
  def is_nil_or_empty?(_), do: false

  def is_number_matching_description?(number, %PhoneNumberDescription{} = description)
      when is_binary(number) do
    if description.possible_number_pattern == Values.description_default_pattern() or
         description.national_number_pattern == Values.description_default_pattern() do
      false
    else
      matches_entirely?(description.possible_number_pattern, number) and
        matches_entirely?(description.national_number_pattern, number)
    end
  end

  def matches_entirely?(nil, _string), do: false

  def matches_entirely?(regex, string) do
    regex = ~r/^(?:#{regex.source})$/

    case Regex.run(regex, string, return: :index) do
      [{_index, length} | _tail] -> Kernel.byte_size(string) == length
      _ -> false
    end
  end
end

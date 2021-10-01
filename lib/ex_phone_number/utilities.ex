defmodule ExPhoneNumber.Utilities do
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Model.PhoneNumber
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

  @doc """
  Attempts to extract a valid number from a phone number that is too long to be
  valid, and resets the PhoneNumber object passed in to that valid version. If
  no valid number could be extracted, the PhoneNumber object passed in will not
  be modified.
  """
  @spec truncate_too_long_number(%PhoneNumber{}) :: {:ok, %PhoneNumber{}} | {:error, %PhoneNumber{}} 
  def truncate_too_long_number(%PhoneNumber{} = phone_number) do 
    case truncate_number(phone_number) do 
      :error -> {:error, phone_number}
      other -> other
    end
  end

  def truncate_too_long_number(other) do 
    raise ArgumentError, "expected an %ExPhoneNumber.Model.PhoneNumber{} received #{inspect other}"
  end

  defp truncate_number(%PhoneNumber{national_number: 0}) do 
    :error
  end

  defp truncate_number(number) do 
    if ExPhoneNumber.Validation.is_valid_number?(number) do
      {:ok, number}
    else
      truncate_number(Map.replace(number, :national_number, div(number.national_number, 10)))
    end
  end
end

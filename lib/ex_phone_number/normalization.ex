defmodule ExPhoneNumber.Normalization do
  @moduledoc false

  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.Mappings
  alias ExPhoneNumber.Constants.Patterns

  def convert_alpha_chars_in_number(number) do
    normalize_helper(number, Mappings.all_normalization_mappings(), false)
  end

  def match_at_start?(string, pattern) when is_binary(string) and is_map(pattern) do
    case Regex.run(pattern, string, return: :index) do
      [{index, _length} | _tail] -> index == 0
      nil -> false
    end
  end

  def normalize(number) do
    if matches_entirely?(Patterns.valid_alpha_phone_pattern(), number) do
      normalize_helper(number, Mappings.all_normalization_mappings(), true)
    else
      normalize_digits_only(number)
    end
  end

  def normalize_digits_only(number) do
    normalize_helper(number, Mappings.digit_mappings(), true)
  end

  def normalize_helper(number, normalization_replacements, remove_non_matches)
      when is_binary(number) and is_map(normalization_replacements) and
             is_boolean(remove_non_matches) do
    number
    |> String.codepoints()
    |> Enum.reduce([], fn char, list ->
      new_char = Map.get(normalization_replacements, String.upcase(char))

      if new_char do
        [new_char | list]
      else
        if remove_non_matches do
          list
        else
          [char | list]
        end
      end
    end)
    |> Enum.reverse()
    |> List.to_string()
  end

  def split_at_match_and_return_head(string, pattern)
      when is_binary(string) and is_map(pattern) do
    case Regex.run(pattern, string, return: :index) do
      [{index, _length} | _tail] ->
        {head, _tail} = String.split_at(string, index)
        head

      nil ->
        string
    end
  end

  def split_at_match_and_return_head(string, pattern)
      when is_binary(string) and is_binary(pattern) do
    case :binary.match(string, pattern) do
      {pos, _length} ->
        {head, _tail} = String.split_at(string, pos)
        head

      :nomatch ->
        string
    end
  end
end

defmodule ExPhoneNumber.Constants.Patterns do
  alias ExPhoneNumber.Constants.Values

  @unique_international_prefix "[\d]+(?:[~\u2053\u223C\uFF5E][\d]+)?"
  @unique_international_prefix_regex Regex.compile(@unique_international_prefix)
  def unique_international_prefix() do
    @unique_international_prefix_regex
  end

  def valid_punctuation() do
    "-x\u2010-\u2015\u2212\u30FC\uFF0D-\uFF0F \u00A0\u00AD\u200B\u2060\u3000" <>
      "()\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E"
  end

  def valid_digits(), do: "0-9\uFF10-\uFF19\u0660-\u0669\u06F0-\u06F9"

  def valid_alpha(), do: "A-Za-z"

  def plus_chars(), do: "+\uFF0B"

  def plus_chars_pattern(), do: ~r/[#{plus_chars()}]+/u

  def leading_plus_chars_pattern(), do: ~r/^[#{plus_chars()}]+/u

  def separator_pattern(), do: ~r/[#{valid_punctuation()}]+/u

  def capturing_digit_pattern(), do: ~r/([#{valid_digits()}])/u

  def valid_start_char_pattern(), do: ~r/[#{plus_chars()}#{valid_digits()}]/u

  def second_number_start_pattern(), do: ~r/[\\\/] *x/u

  def unwanted_end_char_pattern(), do: ~r/[^#{valid_digits()}#{valid_alpha()}#]+$/u

  def valid_alpha_phone_pattern(), do: ~r/(?:.*?[A-Za-z]){3}.*/u

  def min_length_phone_number_pattern(),
    do: "[" <> valid_digits() <> "]{" <> Integer.to_string(Values.min_length_for_nsn()) <> "}"

  def valid_phone_number() do
    "[" <>
      plus_chars() <>
      "]*(?:[" <>
      valid_punctuation() <>
      Values.star_sign() <>
      "]*[" <>
      valid_digits() <>
      "]){3,}[" <>
      valid_punctuation() <>
      Values.star_sign() <>
      valid_alpha() <>
      valid_digits() <> "]*"
  end

  def default_extn_prefix(), do: " ext. "

  def capturing_extn_digits(), do: "([" <> valid_digits() <> "]{1,7})"

  def extn_patterns_for_parsing() do
    Values.rfc3966_extn_prefix() <>
      capturing_extn_digits() <>
      "|" <>
      "[ \u00A0\\t,]*" <>
      "(?:e?xt(?:ensi(?:o\u0301?|\u00F3))?n?|\uFF45?\uFF58\uFF54\uFF4E?|" <>
      "[,x\uFF58#\uFF03~\uFF5E]|int|anexo|\uFF49\uFF4E\uFF54)" <>
      "[:\\.\uFF0E]?[ \u00A0\\t,-]*" <>
      capturing_extn_digits() <>
      "#?|" <>
      "[- ]+([" <> valid_digits() <> "]{1,5})#"
  end

  def extn_pattern(), do: ~r/(?:#{extn_patterns_for_parsing()})$/iu

  def valid_phone_number_pattern() do
    ~r/^#{min_length_phone_number_pattern()}$|^#{valid_phone_number()}(?:#{extn_patterns_for_parsing()})?$/iu
  end

  def non_digits_pattern(), do: ~r/\D+/u

  def first_group_pattern(), do: ~r/(\\g{\d})/u

  def np_pattern(), do: ~r/\$NP/u

  def fg_pattern(), do: ~r/\$FG/u

  def cc_pattern(), do: ~r/\$CC/u

  def first_group_only_prefix_pattern(), do: ~r/^\(?\$1\)?$/u
end

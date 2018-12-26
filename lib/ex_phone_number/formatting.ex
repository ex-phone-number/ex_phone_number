defmodule ExPhoneNumber.Formatting do
  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.Patterns
  alias ExPhoneNumber.Constants.PhoneNumberFormats
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Model.PhoneNumber

  def choose_formatting_pattern_for_number(available_formats, national_number) do
    Enum.find(available_formats, fn number_format ->
      leading_digits_pattern_size = length(number_format.leading_digits_pattern)

      match_index =
        if not (leading_digits_pattern_size == 0) do
          last_leading_digits_pattern = List.last(number_format.leading_digits_pattern)

          case Regex.run(last_leading_digits_pattern, national_number, return: :index) do
            nil -> -1
            [{match_index, _match_length} | _tail] -> match_index
          end
        else
          -1
        end

      if leading_digits_pattern_size == 0 or match_index == 0 do
        matches_entirely?(number_format.pattern, national_number)
      end
    end)
  end

  def format(%PhoneNumber{} = phone_number, phone_number_format) when is_atom(phone_number_format) do
    if phone_number.national_number == 0 and not is_nil_or_empty?(phone_number.raw_input) do
      phone_number.raw_input
    else
      national_significant_number = PhoneNumber.get_national_significant_number(phone_number)

      if PhoneNumberFormats.e164() == phone_number_format do
        prefix_number_with_country_calling_code(
          phone_number.country_code,
          phone_number_format,
          national_significant_number,
          ""
        )
      else
        if not Metadata.is_valid_country_code?(phone_number.country_code) do
          national_significant_number
        else
          region_code = Metadata.get_region_code_for_country_code(phone_number.country_code)
          metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
          formatted_extension = maybe_get_formatted_extension(phone_number, metadata, phone_number_format)
          formatted_national_number = format_nsn(national_significant_number, metadata, phone_number_format)

          prefix_number_with_country_calling_code(
            phone_number.country_code,
            phone_number_format,
            formatted_national_number,
            formatted_extension
          )
        end
      end
    end
  end

  def format_nsn(number, %PhoneMetadata{} = metadata, number_format, carrier_code \\ nil) do
    available_formats =
      if length(metadata.intl_number_format) == 0 or PhoneNumberFormats.national() == number_format do
        metadata.number_format
      else
        metadata.intl_number_format
      end

    formatting_pattern = choose_formatting_pattern_for_number(available_formats, number)

    if is_nil(formatting_pattern) do
      number
    else
      format_nsn_using_pattern(number, formatting_pattern, number_format, carrier_code)
    end
  end

  def format_nsn_using_pattern(number, formatting_pattern, phone_number_format, carrier_code) do
    formatted_national_number =
      if PhoneNumberFormats.national() == phone_number_format and not is_nil_or_empty?(carrier_code) and
           not is_nil_or_empty?(formatting_pattern.domestic_carrier_code_formatting_rule) do
        carrier_code_rule =
          Regex.replace(
            Patterns.cc_pattern(),
            formatting_pattern.domestic_carrier_code_formatting_rule,
            carrier_code
          )

        number_rule =
          Regex.replace(Patterns.first_group_pattern(), formatting_pattern.format, carrier_code_rule)

        Regex.replace(formatting_pattern.pattern, number, number_rule)
      else
        if PhoneNumberFormats.national() == phone_number_format and
             not is_nil_or_empty?(formatting_pattern.national_prefix_formatting_rule) do
          number_rule =
            Regex.replace(
              Patterns.first_group_pattern(),
              formatting_pattern.format,
              formatting_pattern.national_prefix_formatting_rule,
              global: false
            )

          Regex.replace(formatting_pattern.pattern, number, number_rule)
        else
          Regex.replace(formatting_pattern.pattern, number, formatting_pattern.format)
        end
      end

    if PhoneNumberFormats.rfc3966() == phone_number_format do
      new_formatted_national_number =
        Regex.replace(~r/^#{Patterns.separator_pattern().source}/, formatted_national_number, "")

      Regex.replace(Patterns.separator_pattern(), new_formatted_national_number, "-")
    else
      formatted_national_number
    end
  end

  def maybe_get_formatted_extension(
        %PhoneNumber{} = phone_number,
        %PhoneMetadata{} = metadata,
        phone_number_format
      )
      when is_atom(phone_number_format) do
    if not PhoneNumber.has_extension?(phone_number) or String.length(phone_number.extension) == 0 do
      ""
    else
      if PhoneNumberFormats.rfc3966() == phone_number_format do
        Values.rfc3966_extn_prefix() <> phone_number.extension
      else
        if PhoneMetadata.has_preferred_extn_prefix?(metadata) do
          metadata.preferred_extn_prefix <> phone_number.extension
        else
          Values.default_extn_prefix() <> phone_number.extension
        end
      end
    end
  end

  def prefix_number_with_country_calling_code(
        country_code,
        phone_number_format,
        formatted_national_number,
        formatted_extension
      ) do
    country_code_string = Integer.to_string(country_code)

    cond do
      PhoneNumberFormats.e164() == phone_number_format ->
        Values.plus_sign() <> country_code_string <> formatted_national_number <> formatted_extension

      PhoneNumberFormats.international() == phone_number_format ->
        Values.plus_sign() <> country_code_string <> " " <> formatted_national_number <> formatted_extension

      PhoneNumberFormats.rfc3966() == phone_number_format ->
        Values.rfc3966_prefix() <>
          Values.plus_sign() <> country_code_string <> "-" <> formatted_national_number <> formatted_extension

      PhoneNumberFormats.national() == phone_number_format ->
        formatted_national_number <> formatted_extension

      true ->
        formatted_national_number <> formatted_extension
    end
  end
end

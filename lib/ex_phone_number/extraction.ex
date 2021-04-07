defmodule ExPhoneNumber.Extraction do
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.CountryCodeSource
  alias ExPhoneNumber.Constants.ErrorMessages
  alias ExPhoneNumber.Constants.Patterns
  alias ExPhoneNumber.Constants.ValidationResults
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Model.PhoneNumber

  def extract_country_code(full_number) when is_binary(full_number) do
    if String.length(full_number) == 0 or String.at(full_number, 0) == "0" do
      {0, ""}
    else
      extract_country_code(1, full_number)
    end
  end

  def extract_country_code(index, full_number) when is_number(index) and is_binary(full_number) do
    if not (index <= Values.max_length_country_code() and index <= String.length(full_number)) do
      {0, ""}
    else
      split = String.split_at(full_number, index)

      case Integer.parse(elem(split, 0)) do
        {int, _bin} ->
          if Metadata.is_valid_country_code?(int) do
            {int, elem(split, 1)}
          else
            extract_country_code(index + 1, full_number)
          end

        :error ->
          {0, ""}
      end
    end
  end

  def extract_possible_number(number_to_parse) do
    case Regex.run(Patterns.valid_start_char_pattern(), number_to_parse, return: :index) do
      [{index, _length} | _tail] ->
        {_head, tail} = String.split_at(number_to_parse, index)

        tail
        |> split_at_match_and_return_head(Patterns.unwanted_end_char_pattern())
        |> split_at_match_and_return_head(Patterns.second_number_start_pattern())

      nil ->
        ""
    end
  end

  def maybe_extract_country_code(number, _metadata, _keep_raw_input) when length(number) == 0,
    do: {false, number, %{country_code: 0}}

  def maybe_extract_country_code(number, metadata, keep_raw_input)
      when is_binary(number) and is_boolean(keep_raw_input) do
    possible_country_idd_prefix = if not is_nil(metadata), do: metadata.international_prefix

    possible_country_idd_prefix = if is_nil(possible_country_idd_prefix), do: "NonMatch", else: possible_country_idd_prefix

    {country_code_source, full_number} = maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix)

    phone_number =
      if keep_raw_input,
        do: %PhoneNumber{country_code_source: country_code_source},
        else: %PhoneNumber{}

    if country_code_source != CountryCodeSource.from_default_country() do
      if String.length(full_number) <= Values.min_length_for_nsn() do
        {false, ErrorMessages.too_short_after_idd()}
      else
        {country_code, national_number} = extract_country_code(full_number)

        if country_code != 0 do
          {true, national_number, %{phone_number | country_code: country_code}}
        else
          {false, ErrorMessages.invalid_country_code()}
        end
      end
    else
      if not is_nil(metadata) do
        country_code_string = Integer.to_string(metadata.country_code)

        if String.starts_with?(full_number, country_code_string) do
          {_, potential_national_number} = String.split_at(full_number, String.length(country_code_string))

          {result, _, possible_national_number} = maybe_strip_national_prefix_and_carrier_code(potential_national_number, metadata)

          potential_national_number = if result, do: possible_national_number, else: potential_national_number

          if (not matches_entirely?(metadata.general.national_number_pattern, full_number) and
                matches_entirely?(
                  metadata.general.national_number_pattern,
                  potential_national_number
                )) or
               test_number_length(full_number, metadata) == ValidationResults.too_long() do
            phone_number =
              if keep_raw_input,
                do: %{
                  phone_number
                  | country_code: metadata.country_code,
                    country_code_source: CountryCodeSource.from_number_without_plus_sign()
                },
                else: phone_number

            {true, potential_national_number, %{phone_number | country_code: metadata.country_code}}
          else
            {true, full_number, %{phone_number | country_code: 0}}
          end
        else
          {true, full_number, %{phone_number | country_code: 0}}
        end
      else
        {true, full_number, %{phone_number | country_code: 0}}
      end
    end
  end

  def maybe_strip_international_prefix_and_normalize(number, _possible_country_idd_prefix)
      when length(number) == 0,
      do: {CountryCodeSource.from_default_country(), ""}

  def maybe_strip_international_prefix_and_normalize(number, possible_country_idd_prefix) do
    if Regex.match?(Patterns.leading_plus_chars_pattern(), number) do
      stripped_plus_sign = Regex.replace(Patterns.leading_plus_chars_pattern(), number, "")
      {CountryCodeSource.from_number_with_plus_sign(), normalize(stripped_plus_sign)}
    else
      case Regex.compile(possible_country_idd_prefix) do
        {:error, _} ->
          {CountryCodeSource.from_default_country(), ""}

        {:ok, regex} ->
          normalized_number = normalize(number)

          case parse_prefix_as_idd(regex, normalized_number) do
            {false, _} -> {CountryCodeSource.from_default_country(), normalized_number}
            {true, stripped_idd} -> {CountryCodeSource.from_number_with_idd(), stripped_idd}
          end
      end
    end
  end

  def maybe_strip_national_prefix_and_carrier_code(number, %PhoneMetadata{} = metadata) do
    maybe_strip_national_prefix_and_carrier_code(
      number,
      metadata.national_prefix_for_parsing,
      metadata.national_prefix_transform_rule,
      metadata.general.national_number_pattern
    )
  end

  def maybe_strip_national_prefix_and_carrier_code(
        number,
        national_prefix_for_parsing,
        _national_prefix_transform_rule,
        _general_national_number_pattern
      )
      when is_nil(number) or is_nil(national_prefix_for_parsing),
      do: {false, "", number}

  def maybe_strip_national_prefix_and_carrier_code(
        number,
        national_prefix_for_parsing,
        national_prefix_transform_rule,
        general_national_number_pattern
      )
      when is_binary(number) and is_binary(national_prefix_for_parsing) do
    prefix_pattern = ~r/^(?:#{national_prefix_for_parsing})/

    case Regex.run(prefix_pattern, number) do
      nil ->
        {false, "", number}

      matches ->
        is_viable_original_number = matches_entirely?(general_national_number_pattern, number)
        number_of_groups = if length(matches) == 1, do: 1, else: length(matches) - 1
        match = Enum.at(matches, number_of_groups)
        number_stripped = elem(String.split_at(number, String.length(Enum.at(matches, 0))), 1)
        is_nil_transform_rule = is_nil_or_empty?(national_prefix_transform_rule)
        is_nil_match = is_nil_or_empty?(match)
        no_transform = is_nil_transform_rule or is_nil_match

        if no_transform do
          if is_viable_original_number and
               not matches_entirely?(general_national_number_pattern, number_stripped) do
            {false, "", number}
          else
            carrier_code =
              if length(matches) > 0 and not is_nil(Enum.at(matches, number_of_groups)),
                do: Enum.at(matches, 1)

            {true, carrier_code, number_stripped}
          end
        else
          transformed_number = Regex.replace(prefix_pattern, number, national_prefix_transform_rule)

          if is_viable_original_number and
               not matches_entirely?(general_national_number_pattern, transformed_number) do
            {false, "", number}
          else
            carrier_code = if length(matches) > 0, do: Enum.at(matches, 1)
            {true, carrier_code, transformed_number}
          end
        end
    end
  end

  def parse_prefix_as_idd(pattern, number) do
    case Regex.run(pattern, number, return: :index) do
      [{index, match_length} | _tail] ->
        if index == 0 do
          {_, number_tail} = String.split_at(number, match_length)
          matches = Regex.run(Patterns.capturing_digit_pattern(), number_tail)
          match_is_nil = is_nil(matches)
          capture = if match_is_nil, do: "", else: Enum.at(matches, 1)
          normalized_group = normalize_digits_only(capture)

          if normalized_group == "0" do
            {false, number}
          else
            {true, number_tail}
          end
        else
          {false, number}
        end

      nil ->
        {false, number}
    end
  end
end

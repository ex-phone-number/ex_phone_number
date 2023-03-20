defmodule ExPhoneNumber.Parsing do
  @moduledoc false

  import ExPhoneNumber.Extraction
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.ErrorMessages
  alias ExPhoneNumber.Constants.Patterns
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Model.PhoneNumber

  def build_national_number_for_parsing(number_to_parse) do
    number_to_parse
    |> String.split(Values.rfc3966_phone_context(), parts: 2)
    |> case do
      [number_head, number_tail] ->
        if String.starts_with?(number_tail, Values.plus_sign()) do
          case String.split(number_tail, ";", parts: 2) do
            [phone_context_head, _] -> phone_context_head
            [_] -> number_tail
          end
        else
          ""
        end <>
          case String.split(number_head, Values.rfc3966_prefix(), parts: 2) do
            [_, national_number_tail] -> national_number_tail
            [_] -> number_head
          end

      [_] ->
        extract_possible_number(number_to_parse)
    end
    |> split_at_match_and_return_head(Values.rfc3966_isdn_subaddress())
  end

  def check_region_for_parsing(number_to_parse, default_region) do
    Metadata.is_valid_region_code?(default_region) or
      Regex.match?(Patterns.leading_plus_chars_pattern(), number_to_parse)
  end

  def is_possible_number?(number, region_code) when is_binary(number) do
    case parse(number, region_code) do
      {:ok, phone_number} -> is_possible_number?(phone_number)
      {:error, _} -> false
    end
  end

  def parse(number_to_parse, default_region) do
    parse_helper(number_to_parse, default_region, false, true)
  end

  def parse_helper(number_to_parse, _default_region, _keep_raw_input, _check_region)
      when is_nil(number_to_parse),
      do: {:error, ErrorMessages.not_a_number()}

  def parse_helper(number_to_parse, default_region, keep_raw_input, check_region)
      when is_binary(number_to_parse) and is_boolean(keep_raw_input) and is_boolean(check_region) do
    results_tuple =
      case validate_length(number_to_parse) do
        {:error, message} ->
          {:error, message}

        {:ok, number_to_parse} ->
          national_number = build_national_number_for_parsing(number_to_parse)

          if not is_viable_phone_number?(national_number) do
            {:error, ErrorMessages.not_a_number()}
          else
            if check_region and not check_region_for_parsing(national_number, default_region) do
              {:error, ErrorMessages.invalid_country_code()}
            else
              {:ok, national_number, default_region}
            end
          end
      end

    results_tuple =
      if :ok == elem(results_tuple, 0) do
        {_, national_number, _} = results_tuple

        phone_number = if keep_raw_input, do: %PhoneNumber{raw_input: number_to_parse}, else: %PhoneNumber{}

        {ext, national_number} = maybe_strip_extension(national_number)

        phone_number = if not is_nil_or_empty?(ext), do: %{phone_number | extension: ext}, else: phone_number

        region_metadata = Metadata.get_for_region_code(default_region)

        case maybe_extract_country_code(national_number, region_metadata, keep_raw_input) do
          {true, normalized_national_number, phone_number_extract} ->
            if phone_number_extract.country_code != 0 do
              phone_number_region_code = Metadata.get_region_code_for_country_code(phone_number_extract.country_code)

              phone_number_region_metadata =
                if phone_number_region_code != default_region do
                  Metadata.get_for_region_code_or_calling_code(
                    phone_number_extract.country_code,
                    phone_number_region_code
                  )
                else
                  region_metadata
                end

              {:ok, normalized_national_number, phone_number_region_metadata, Map.merge(phone_number, phone_number_extract, &update_if_nil/3)}
            else
              new_normalized_national_number = normalize(national_number)

              phone_number_extract = %{
                phone_number_extract
                | country_code: region_metadata.country_code
              }

              phone_number_extract =
                if keep_raw_input,
                  do: %{phone_number_extract | country_code_source: nil},
                  else: phone_number_extract

              {:ok, new_normalized_national_number, region_metadata, Map.merge(phone_number, phone_number_extract, &update_if_nil/3)}
            end

          {false, message} ->
            if message == ErrorMessages.invalid_country_code() and
                 Regex.match?(Patterns.leading_plus_chars_pattern(), national_number) do
              national_number_without_plus_sign = String.replace(national_number, Patterns.leading_plus_chars_pattern(), "")

              case maybe_extract_country_code(
                     national_number_without_plus_sign,
                     region_metadata,
                     keep_raw_input
                   ) do
                {true, normalized_national_number, phone_number_extract} ->
                  if phone_number_extract.country_code == 0 do
                    {:error, message}
                  else
                    {:ok, normalized_national_number, region_metadata, Map.merge(phone_number, phone_number_extract, &update_if_nil/3)}
                  end

                {false, message} ->
                  {:error, message}
              end
            else
              {:error, message}
            end
        end
      else
        results_tuple
      end

    results_tuple =
      if :ok == elem(results_tuple, 0) do
        {_, normalized_national_number, metadata, phone_number} = results_tuple

        if not is_nil(metadata) do
          case maybe_strip_national_prefix_and_carrier_code(normalized_national_number, metadata) do
            {true, carrier_code, potential_national_number} ->
              national_number =
                if is_valid_possible_number_length?(
                     metadata,
                     potential_national_number
                   ),
                   do: potential_national_number,
                   else: normalized_national_number

              phone_number =
                if keep_raw_input,
                  do: %{phone_number | preferred_domestic_carrier_code: carrier_code},
                  else: phone_number

              {:ok, national_number, phone_number}

            {false, _, _} ->
              {:ok, normalized_national_number, phone_number}
          end
        else
          {:ok, normalized_national_number, phone_number}
        end
      else
        results_tuple
      end

    results_tuple =
      if :ok == elem(results_tuple, 0) do
        {_, normalized_national_number, phone_number} = results_tuple

        cond do
          String.length(normalized_national_number) < Values.min_length_for_nsn() ->
            {:error, ErrorMessages.too_short_nsn()}

          String.length(normalized_national_number) > Values.max_length_for_nsn() ->
            {:error, ErrorMessages.too_long()}

          true ->
            phone_number_add = PhoneNumber.set_italian_leading_zeros(normalized_national_number, phone_number)

            case Integer.parse(normalized_national_number) do
              {int, _} ->
                {:ok, %{phone_number_add | national_number: int}}

              :error ->
                {:ok, phone_number_add}
            end
        end
      else
        results_tuple
      end

    results_tuple
  end

  defp update_if_nil(_k, v1, v2) do
    if is_nil(v2), do: v1, else: v2
  end
end

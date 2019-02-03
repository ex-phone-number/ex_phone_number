defmodule ExPhoneNumber.Validation do
  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.ErrorMessages
  alias ExPhoneNumber.Constants.Patterns
  alias ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.ValidationResults
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Model.PhoneNumber

  def get_number_type(%PhoneNumber{} = phone_number) do
    region_code = Metadata.get_region_code_for_number(phone_number)
    metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
    if metadata == nil do
      PhoneNumberTypes.unknown
    else
      national_significant_number = PhoneNumber.get_national_significant_number(phone_number)
      get_number_type_helper(national_significant_number, metadata)
    end
  end

  def get_number_type_helper(national_number, metadata = %PhoneMetadata{}) do
    cond do
      not is_number_matching_description?(national_number, metadata.general) -> PhoneNumberTypes.unknown
      is_number_matching_description?(national_number, metadata.premium_rate) -> PhoneNumberTypes.premium_rate
      is_number_matching_description?(national_number, metadata.toll_free) -> PhoneNumberTypes.toll_free
      is_number_matching_description?(national_number, metadata.shared_cost) -> PhoneNumberTypes.shared_cost
      is_number_matching_description?(national_number, metadata.voip) -> PhoneNumberTypes.voip
      is_number_matching_description?(national_number, metadata.personal_number) -> PhoneNumberTypes.personal_number
      is_number_matching_description?(national_number, metadata.pager) -> PhoneNumberTypes.pager
      is_number_matching_description?(national_number, metadata.uan) -> PhoneNumberTypes.uan
      is_number_matching_description?(national_number, metadata.voicemail) -> PhoneNumberTypes.voicemail
      is_number_matching_description?(national_number, metadata.fixed_line) ->
        if metadata.same_mobile_and_fixed_line_pattern do
          PhoneNumberTypes.fixed_line_or_mobile
        else
          if is_number_matching_description?(national_number, metadata.mobile) do
            PhoneNumberTypes.fixed_line_or_mobile
          else
            PhoneNumberTypes.fixed_line
          end
        end
      is_number_matching_description?(national_number, metadata.mobile) -> PhoneNumberTypes.mobile
      true -> PhoneNumberTypes.unknown
    end
  end

  def is_number_geographical?(%PhoneNumber{} = phone_number) do
    number_type = get_number_type(phone_number)
    number_type == PhoneNumberTypes.fixed_line or number_type == PhoneNumberTypes.fixed_line_or_mobile
  end

  def is_possible_number?(%PhoneNumber{} = number) do
    ValidationResults.is_possible == is_possible_number_with_reason?(number)
  end

  def is_possible_number_with_reason?(%PhoneNumber{} = number) do
    if not Metadata.is_valid_country_code?(number.country_code) do
      ValidationResults.invalid_country_code
    else
      region_code = Metadata.get_region_code_for_country_code(number.country_code)
      metadata = Metadata.get_for_region_code_or_calling_code(number.country_code, region_code)
      national_number = PhoneNumber.get_national_significant_number(number)
      test_number_length(national_number, metadata)
    end
  end

  def is_shorter_than_possible_normal_number?(metadata, number) do
    test_number_length(number, metadata) == ValidationResults.too_short
  end

  def is_valid_number?(%PhoneNumber{} = number) do
    region_code = Metadata.get_region_code_for_number(number)
    is_valid_number_for_region?(number, region_code)
  end

  def is_valid_number_for_region?(%PhoneNumber{} = _number, nil), do: false
  def is_valid_number_for_region?(%PhoneNumber{} = number, region_code) when is_binary(region_code) do
    metadata = Metadata.get_for_region_code_or_calling_code(number.country_code, region_code)
    is_invalid_code = Values.region_code_for_non_geo_entity != region_code and number.country_code != Metadata.get_country_code_for_valid_region(region_code)
    if is_nil(metadata) or is_invalid_code do
      false
    else
      national_significant_number = PhoneNumber.get_national_significant_number(number)
      get_number_type_helper(national_significant_number, metadata) != PhoneNumberTypes.unknown
    end
  end

  def is_viable_phone_number?(phone_number) do
    if String.length(phone_number) < Values.min_length_for_nsn do
      false
    else
      matches_entirely?(Patterns.valid_phone_number_pattern, phone_number)
    end
  end

  def test_number_length(number, metadata) do
    test_number_length_for_type(number, metadata, PhoneNumberTypes.unknown)
  end

  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > Values.max_input_string_length do
      {:error, ErrorMessages.too_long()}
    else
      {:ok, number_to_parse}
    end
  end

  defp test_number_length_for_type(number, metadata, type) do
    possible_lengths =
      if type == PhoneNumberTypes.fixed_line_or_mobile() do
        possible_lengths_by_type(metadata, PhoneNumberTypes.fixed_line())
        ++ possible_lengths_by_type(metadata, PhoneNumberTypes.mobile())
        |> Enum.uniq
      else
        possible_lengths_by_type(metadata, type)
      end

    min_length = Enum.min(possible_lengths)
    max_length = Enum.max(possible_lengths)

    if(min_length == -1) do
      ValidationResults.invalid_length
    else
      case String.length(number) do
        actual_length when (actual_length < min_length) -> ValidationResults.too_short
        actual_length when (actual_length > max_length) -> ValidationResults.too_long
        actual_length ->
          if Enum.member?(possible_lengths, actual_length) do
            ValidationResults.is_possible
          else
            ValidationResults.invalid_length
          end
      end
    end
  end

  defp possible_lengths_by_type(metadata, type) do
    desc_for_type = get_number_description_by_type(metadata, type)
    desc_general = get_number_description_by_type(metadata, :general)

    if Enum.empty?(desc_for_type.possible_lengths) do
      desc_general.possible_lengths
    else
      desc_for_type.possible_lengths
    end
  end

  defp get_number_description_by_type(%PhoneMetadata{} = metadata, type) do
    cond do
      type == PhoneNumberTypes.premium_rate -> metadata.premium_rate
      type == PhoneNumberTypes.toll_free -> metadata.toll_free
      type == PhoneNumberTypes.mobile -> metadata.mobile
      type == PhoneNumberTypes.fixed_line -> metadata.fixed_line
      type == PhoneNumberTypes.shared_cost -> metadata.shared_cost
      type == PhoneNumberTypes.voip -> metadata.voip
      type == PhoneNumberTypes.personal_number -> metadata.personal_number
      type == PhoneNumberTypes.pager -> metadata.pager
      type == PhoneNumberTypes.uan -> metadata.uan
      type == PhoneNumberTypes.voicemail -> metadata.voicemail
      true -> metadata.general
    end
  end
end

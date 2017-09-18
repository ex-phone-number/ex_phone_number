defmodule ExPhoneNumber.Validation do
  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.{
    ErrorMessages,
    Patterns,
    PhoneNumberTypes,
    ValidationResults,
    Values
  }
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Model.PhoneNumber

  def get_number_description_by_type(phone_metadata = %PhoneMetadata{}, type) do
    cond do
      type == PhoneNumberTypes.premium_rate -> phone_metadata.premium_rate
      type == PhoneNumberTypes.toll_free -> phone_metadata.toll_free
      type == PhoneNumberTypes.mobile -> phone_metadata.mobile
      type == PhoneNumberTypes.fixed_line -> phone_metadata.fixed_line
      type == PhoneNumberTypes.fixed_line_or_mobile -> phone_metadata.fixed_line
      type == PhoneNumberTypes.shared_cost -> phone_metadata.shared_cost
      type == PhoneNumberTypes.voip -> phone_metadata.voip
      type == PhoneNumberTypes.personal_number -> phone_metadata.personal_number
      type == PhoneNumberTypes.pager -> phone_metadata.pager
      type == PhoneNumberTypes.uan -> phone_metadata.uan
      type == PhoneNumberTypes.voicemail -> phone_metadata.voicemail
      true -> phone_metadata.general
    end
  end

  def get_number_type(phone_number = %PhoneNumber{}) do
    region_code = Metadata.get_region_code_for_number(phone_number)
    metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
    if metadata == nil do
      PhoneNumberTypes.unknown
    else
      national_significant_number = PhoneNumber.get_national_significant_number(phone_number)
      get_number_type_helper(national_significant_number, metadata)
    end
  end

  def get_number_type_helper(national_number, phone_metadata = %PhoneMetadata{}) do
    cond do
      not is_number_matching_description?(national_number, phone_metadata.general) -> PhoneNumberTypes.unknown
      is_number_matching_description?(national_number, phone_metadata.premium_rate) -> PhoneNumberTypes.premium_rate
      is_number_matching_description?(national_number, phone_metadata.toll_free) -> PhoneNumberTypes.toll_free
      is_number_matching_description?(national_number, phone_metadata.shared_cost) -> PhoneNumberTypes.shared_cost
      is_number_matching_description?(national_number, phone_metadata.voip) -> PhoneNumberTypes.voip
      is_number_matching_description?(national_number, phone_metadata.personal_number) -> PhoneNumberTypes.personal_number
      is_number_matching_description?(national_number, phone_metadata.pager) -> PhoneNumberTypes.pager
      is_number_matching_description?(national_number, phone_metadata.uan) -> PhoneNumberTypes.uan
      is_number_matching_description?(national_number, phone_metadata.voicemail) -> PhoneNumberTypes.voicemail
      is_number_matching_description?(national_number, phone_metadata.fixed_line) ->
        if phone_metadata.same_mobile_and_fixed_line_pattern do
          PhoneNumberTypes.fixed_line_or_mobile
        else
          if is_number_matching_description?(national_number, phone_metadata.mobile) do
            PhoneNumberTypes.fixed_line_or_mobile
          else
            PhoneNumberTypes.fixed_line
          end
        end
      is_number_matching_description?(national_number, phone_metadata.mobile) -> PhoneNumberTypes.mobile
      true -> PhoneNumberTypes.unknown
    end
  end

  def is_number_geographical?(phone_number = %PhoneNumber{}) do
    number_type = get_number_type(phone_number)
    number_type == PhoneNumberTypes.fixed_line or number_type == PhoneNumberTypes.fixed_line_or_mobile
  end

  def is_possible_number?(phone_number = %PhoneNumber{}) do
    ValidationResults.is_possible == is_possible_number_with_reason?(phone_number)
  end

  def is_possible_number_with_reason?(phone_number = %PhoneNumber{}) do
    if not Metadata.is_valid_country_code?(phone_number.country_code) do
      ValidationResults.invalid_country_code
    else
      region_code = Metadata.get_region_code_for_country_code(phone_number.country_code)
      metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
      national_number = PhoneNumber.get_national_significant_number(phone_number)
      test_number_length_against_pattern(metadata.general.possible_number_pattern, national_number)
    end
  end

  def is_shorter_than_possible_normal_number?(metadata, number) do
    test_number_length_against_pattern(metadata.general.possible_number_pattern, number) == ValidationResults.too_short
  end

  def is_valid_number?(phone_number = %PhoneNumber{}) do
    region_code = Metadata.get_region_code_for_number(phone_number)
    is_valid_number_for_region?(phone_number, region_code)
  end

  def is_valid_number_for_region?(_phone_number = %PhoneNumber{}, nil), do: false
  def is_valid_number_for_region?(phone_number = %PhoneNumber{}, region_code) when is_binary(region_code) do
    metadata = Metadata.get_for_region_code_or_calling_code(phone_number.country_code, region_code)
    is_invalid_code = Values.region_code_for_non_geo_entity != region_code and phone_number.country_code != Metadata.get_country_code_for_valid_region(region_code)
    if is_nil(metadata) or is_invalid_code do
      false
    else
      national_significant_number = PhoneNumber.get_national_significant_number(phone_number)
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

  def test_number_length_against_pattern(pattern, number) do
    if matches_entirely?(pattern, number) do
      ValidationResults.is_possible
    else
      case Regex.run(pattern, number, return: :index) do
        [{index, _match_length} | _tail] -> if index == 0, do: ValidationResults.too_long, else: ValidationResults.too_short
        nil -> ValidationResults.too_short
      end
    end
  end

  def validate_length(number_to_parse) do
    if String.length(number_to_parse) > Values.max_input_string_length do
      {:error, ErrorMessages.too_long()}
    else
      {:ok, number_to_parse}
    end
  end
end

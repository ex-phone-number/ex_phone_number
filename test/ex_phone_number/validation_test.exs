defmodule ExPhoneNumber.ValidationTest do
  use ExUnit.Case, async: true

  doctest ExPhoneNumber.Validation

  import ExPhoneNumber.Validation

  alias ExPhoneNumber.{PhoneNumberFixture, RegionCodeFixture}
  alias ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.ValidationResults

  describe ".is_possible_number?/1" do
    test "IsPossibleNumber" do
      assert is_possible_number?(PhoneNumberFixture.us_number())
      assert is_possible_number?(PhoneNumberFixture.us_local_number())
      assert is_possible_number?(PhoneNumberFixture.gb_number())
      assert is_possible_number?(PhoneNumberFixture.international_toll_free())
    end

    test "IsNotPossibleNumber" do
      refute is_possible_number?(PhoneNumberFixture.us_long_number())
      refute is_possible_number?(PhoneNumberFixture.international_toll_free_too_long())
      refute is_possible_number?(PhoneNumberFixture.nanpa_short_number())
      refute is_possible_number?(PhoneNumberFixture.gb_short_number())
    end
  end

  describe ".is_possible_number_with_reason?/1" do
    test "IsPossibleNumberWithReason" do
      assert ValidationResults.is_possible() == is_possible_number_with_reason?(PhoneNumberFixture.us_number())
      assert ValidationResults.is_possible() == is_possible_number_with_reason?(PhoneNumberFixture.us_local_number())
      assert ValidationResults.too_long() == is_possible_number_with_reason?(PhoneNumberFixture.us_long_number())
      assert ValidationResults.invalid_country_code() == is_possible_number_with_reason?(PhoneNumberFixture.unknown_country_code3())
      assert ValidationResults.too_short() == is_possible_number_with_reason?(PhoneNumberFixture.nanpa_short_number())
      assert ValidationResults.is_possible() == is_possible_number_with_reason?(PhoneNumberFixture.sg_number2())
      assert ValidationResults.too_long() == is_possible_number_with_reason?(PhoneNumberFixture.international_toll_free_too_long())
    end
  end

  describe ".is_viable_phone_number?/1" do
    test "IsViablePhoneNumber" do
      refute is_viable_phone_number?("1")
      refute is_viable_phone_number?("1+1+1")
      refute is_viable_phone_number?("80+0")
      assert is_viable_phone_number?("00")
      assert is_viable_phone_number?("111")
      assert is_viable_phone_number?("0800-4-pizza")
      assert is_viable_phone_number?("0800-4-PIZZA")
      refute is_viable_phone_number?("08-PIZZA")
      refute is_viable_phone_number?("8-PIZZA")
      refute is_viable_phone_number?("12. March")
    end

    test "IsViablePhoneNumberNonAscii" do
      assert is_viable_phone_number?("1\u300034")
      refute is_viable_phone_number?("1\u30003+4")
      assert is_viable_phone_number?("\uFF081\uFF09\u30003456789")
      assert is_viable_phone_number?("+1\uFF09\u30003456789")
    end
  end

  describe ".is_valid_number/1" do
    test "IsValidNumber" do
      assert is_valid_number?(PhoneNumberFixture.us_number())
      assert is_valid_number?(PhoneNumberFixture.it_number())
      assert is_valid_number?(PhoneNumberFixture.gb_mobile())
      assert is_valid_number?(PhoneNumberFixture.international_toll_free())
      assert is_valid_number?(PhoneNumberFixture.universal_premium_rate())
      assert is_valid_number?(PhoneNumberFixture.nz_number2())
    end

    test "IsValidForRegion" do
      assert is_valid_number?(PhoneNumberFixture.bs_number())
      refute is_valid_number?(PhoneNumberFixture.bs_number_invalid())
      assert is_valid_number?(PhoneNumberFixture.re_number())
      refute is_valid_number?(PhoneNumberFixture.re_number_invalid())
    end

    test "IsNotValidNumber" do
      refute is_valid_number?(PhoneNumberFixture.us_local_number())
      refute is_valid_number?(PhoneNumberFixture.it_invalid())
      refute is_valid_number?(PhoneNumberFixture.gb_invalid())
      refute is_valid_number?(PhoneNumberFixture.de_invalid())
      refute is_valid_number?(PhoneNumberFixture.nz_invalid())
      refute is_valid_number?(PhoneNumberFixture.unknown_country_code())
      refute is_valid_number?(PhoneNumberFixture.unknown_country_code2())
      refute is_valid_number?(PhoneNumberFixture.international_toll_free_too_long())
    end

    test "CountryWithNoNumberDesc" do
      refute is_valid_number?(PhoneNumberFixture.ad_number())
    end

    test "UnknownCountryCallingCode" do
      refute is_valid_number?(PhoneNumberFixture.unknown_country_code_no_raw_input())
    end

    test "DE invalid number returns false" do
      {result, phone_number} = ExPhoneNumber.parse("+494915778961257", "DE")

      assert :ok == result
      refute is_valid_number?(phone_number)
    end
  end

  describe ".is_valid_number_for_region?/2" do
    test "IsValidForRegion" do
      assert is_valid_number_for_region?(PhoneNumberFixture.bs_number(), RegionCodeFixture.bs())
      refute is_valid_number_for_region?(PhoneNumberFixture.bs_number(), RegionCodeFixture.us())
      assert is_valid_number_for_region?(PhoneNumberFixture.re_number(), RegionCodeFixture.re())
      refute is_valid_number_for_region?(PhoneNumberFixture.re_number(), RegionCodeFixture.yt())
      assert is_valid_number_for_region?(PhoneNumberFixture.yt_number(), RegionCodeFixture.yt())
      refute is_valid_number_for_region?(PhoneNumberFixture.yt_number(), RegionCodeFixture.re())
      refute is_valid_number_for_region?(PhoneNumberFixture.re_number_invalid(), RegionCodeFixture.re())
      refute is_valid_number_for_region?(PhoneNumberFixture.re_number_invalid(), RegionCodeFixture.yt())
      assert is_valid_number_for_region?(PhoneNumberFixture.re_yt_number(), RegionCodeFixture.re())
      assert is_valid_number_for_region?(PhoneNumberFixture.re_yt_number(), RegionCodeFixture.yt())
      assert is_valid_number_for_region?(PhoneNumberFixture.international_toll_free(), RegionCodeFixture.un001())
      refute is_valid_number_for_region?(PhoneNumberFixture.international_toll_free(), RegionCodeFixture.us())
      refute is_valid_number_for_region?(PhoneNumberFixture.international_toll_free(), RegionCodeFixture.zz())
      refute is_valid_number_for_region?(PhoneNumberFixture.unknown_country_code(), RegionCodeFixture.zz())
      refute is_valid_number_for_region?(PhoneNumberFixture.unknown_country_code(), RegionCodeFixture.un001())
      refute is_valid_number_for_region?(PhoneNumberFixture.unknown_country_code2(), RegionCodeFixture.zz())
      refute is_valid_number_for_region?(PhoneNumberFixture.unknown_country_code2(), RegionCodeFixture.un001())
    end
  end

  describe ".is_number_geographical?/1" do
    test "IsNumberGeographical" do
      refute is_number_geographical?(PhoneNumberFixture.bs_mobile())
      assert is_number_geographical?(PhoneNumberFixture.au_number())
      refute is_number_geographical?(PhoneNumberFixture.international_toll_free())
      assert is_number_geographical?(PhoneNumberFixture.ar_mobile())
      assert is_number_geographical?(PhoneNumberFixture.mx_mobile1())
      assert is_number_geographical?(PhoneNumberFixture.mx_mobile2())
    end
  end

  describe ".get_number_type/1" do
    test "IsPremiumRate" do
      assert PhoneNumberTypes.premium_rate() == get_number_type(PhoneNumberFixture.us_premium())
      assert PhoneNumberTypes.premium_rate() == get_number_type(PhoneNumberFixture.it_premium())
      assert PhoneNumberTypes.premium_rate() == get_number_type(PhoneNumberFixture.gb_premium())
      assert PhoneNumberTypes.premium_rate() == get_number_type(PhoneNumberFixture.de_premium())
      assert PhoneNumberTypes.premium_rate() == get_number_type(PhoneNumberFixture.de_premium2())
      assert PhoneNumberTypes.premium_rate() == get_number_type(PhoneNumberFixture.universal_premium_rate())
    end

    test "IsTollFree" do
      assert PhoneNumberTypes.toll_free() == get_number_type(PhoneNumberFixture.us_tollfree2())
      assert PhoneNumberTypes.toll_free() == get_number_type(PhoneNumberFixture.it_toll_free())
      assert PhoneNumberTypes.toll_free() == get_number_type(PhoneNumberFixture.gb_toll_free())
      assert PhoneNumberTypes.toll_free() == get_number_type(PhoneNumberFixture.de_toll_free())
      assert PhoneNumberTypes.toll_free() == get_number_type(PhoneNumberFixture.international_toll_free())
    end

    test "IsMobile" do
      assert PhoneNumberTypes.mobile() == get_number_type(PhoneNumberFixture.bs_mobile())
      assert PhoneNumberTypes.mobile() == get_number_type(PhoneNumberFixture.gb_mobile())
      assert PhoneNumberTypes.mobile() == get_number_type(PhoneNumberFixture.it_mobile())
      assert PhoneNumberTypes.mobile() == get_number_type(PhoneNumberFixture.ar_mobile())
      assert PhoneNumberTypes.mobile() == get_number_type(PhoneNumberFixture.de_mobile())
    end

    test "IsFixedLine" do
      assert PhoneNumberTypes.fixed_line() == get_number_type(PhoneNumberFixture.bs_number())
      assert PhoneNumberTypes.fixed_line() == get_number_type(PhoneNumberFixture.it_number())
      assert PhoneNumberTypes.fixed_line() == get_number_type(PhoneNumberFixture.gb_number())
      assert PhoneNumberTypes.fixed_line() == get_number_type(PhoneNumberFixture.de_number())
    end

    test "IsFixedLineAndMobile" do
      assert PhoneNumberTypes.fixed_line_or_mobile() == get_number_type(PhoneNumberFixture.us_number())
      assert PhoneNumberTypes.fixed_line_or_mobile() == get_number_type(PhoneNumberFixture.ar_number2())
    end

    test "IsSharedCost" do
      assert PhoneNumberTypes.shared_cost() == get_number_type(PhoneNumberFixture.gb_shared_cost())
    end

    test "IsVoip" do
      assert PhoneNumberTypes.voip() == get_number_type(PhoneNumberFixture.gb_voip())
    end

    test "IsPersonalNumber" do
      assert PhoneNumberTypes.personal_number() == get_number_type(PhoneNumberFixture.gb_personal_number())
    end

    test "IsUnknown" do
      assert PhoneNumberTypes.unknown() == get_number_type(PhoneNumberFixture.us_local_number())
    end

    test "CountryWithNoNumberDesc" do
      assert PhoneNumberTypes.unknown() == get_number_type(PhoneNumberFixture.ad_number())
    end
  end

  describe ".validate_length" do
    test "length less or equal to Constants.Value.max_input_string_length returns {:ok, number}" do
      subject = "1234567890"
      assert {:ok, _} = validate_length(subject)
    end

    test "length larger than Constants.Value.max_input_string_length returns {:error, message}" do
      subject =
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" <>
          "12345678901234567890123456789012345678901234567890123456789012345678901234567890" <>
          "12345678901234567890123456789012345678901234567890123456789012345678901234567890x"

      assert {:error, _} = validate_length(subject)
    end
  end

  describe ".is_alpha_number" do
    test "IsAlphaNumber" do
      assert is_alpha_number("1800 six-flags")
      assert is_alpha_number("1800 six-flags ext. 1234")
      assert is_alpha_number("+800 six-flags")
      assert is_alpha_number("180 six-flags")
      refute is_alpha_number("1800 123-1234")
      refute is_alpha_number("1 six-flags")
      refute is_alpha_number("18 six-flags")
      refute is_alpha_number("1800 123-1234 extension: 1234")
      refute is_alpha_number("+800 1234-1234")
    end
  end
end

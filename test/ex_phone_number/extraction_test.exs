defmodule ExPhoneNumber.ExtractionTest do
  use ExUnit.Case, async: true

  doctest ExPhoneNumber.Extraction

  import ExPhoneNumber.Extraction

  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.PhoneNumberFixture
  alias ExPhoneNumber.RegionCodeFixture
  alias ExPhoneNumber.Constants.CountryCodeSource
  alias ExPhoneNumber.Constants.ErrorMessages

  describe ".extract_possible_number/1" do
    test "ExtractPossibleNumber" do
      assert "0800-345-600" == extract_possible_number("Tel:0800-345-600")
      assert "0800 FOR PIZZA" == extract_possible_number("Tel:0800 FOR PIZZA")
      assert "+800-345-600" == extract_possible_number("Tel:+800-345-600")
      assert "\uFF10\uFF12\uFF13" == extract_possible_number("\uFF10\uFF12\uFF13")
      assert "\uFF11\uFF12\uFF13" == extract_possible_number("Num-\uFF11\uFF12\uFF13")
      assert "" == extract_possible_number("Num-....")
      assert "650) 253-0000" == extract_possible_number("(650) 253-0000")
      assert "650) 253-0000" == extract_possible_number("(650) 253-0000..- ..")
      assert "650) 253-0000" == extract_possible_number("(650) 253-0000.")
      assert "650) 253-0000" == extract_possible_number("(650) 253-0000\u200F")
    end
  end

  describe ".maybe_strip_national_prefix_and_carrier_code/2" do
    def get_national_prefix_metadata do
      %Metadata.PhoneMetadata{
        national_prefix_for_parsing: "34",
        general: %Metadata.PhoneNumberDescription{
          national_number_pattern: ~r/\d{4,8}/
        }
      }
    end

    test "MaybeStripNationalPrefix - Should have had national prefix stripped" do
      metadata = get_national_prefix_metadata()

      {result, _, number} = maybe_strip_national_prefix_and_carrier_code("34356778", metadata)

      assert result
      assert "356778" == number

      {result2, _, number2} = maybe_strip_national_prefix_and_carrier_code(number, metadata)

      refute result2
      assert "356778" == number2
    end

    test "MaybeStripNationalPrefix - Should not strip anything with empty national prefix" do
      metadata = get_national_prefix_metadata()
      metadata = %{metadata | national_prefix_for_parsing: nil}

      {result, _, number} = maybe_strip_national_prefix_and_carrier_code("34356778", metadata)

      refute result
      assert "34356778" == number
    end

    test "MaybeStripNationalPrefix - Should have had no change - after stripping, it would not have matched the national rule" do
      metadata = get_national_prefix_metadata()
      metadata = %{metadata | national_prefix_for_parsing: "3"}

      {result, _, number} = maybe_strip_national_prefix_and_carrier_code("3123", metadata)

      refute result
      assert "3123" == number
    end

    test "MaybeStripNationalPrefix - Should have had national prefix and carrier code stripped" do
      metadata = %Metadata.PhoneMetadata{
        national_prefix_for_parsing: "0(81)?",
        general: %Metadata.PhoneNumberDescription{
          national_number_pattern: ~r/\d{4,8}/
        }
      }

      {result, carrier_code, number} = maybe_strip_national_prefix_and_carrier_code("08122123456", metadata)

      assert result
      assert "81" == carrier_code
      assert "22123456" == number
    end

    test "MaybeStripNationalPrefix - Should transform the 031 to a 5315" do
      metadata = %Metadata.PhoneMetadata{
        national_prefix_for_parsing: "0(\\d{2})",
        national_prefix_transform_rule: "5\\g{1}5",
        general: %Metadata.PhoneNumberDescription{
          national_number_pattern: ~r/\d{4,8}/
        }
      }

      {result, _, number} = maybe_strip_national_prefix_and_carrier_code("031123", metadata)

      assert result
      assert "5315123" == number
    end
  end

  describe ".maybe_strip_international_prefix_and_normalize/2" do
    test "MaybeStripInternationalPrefix 1" do
      {result, number} = maybe_strip_international_prefix_and_normalize("0034567700-3898003", "00[39]")

      assert result == CountryCodeSource.from_number_with_idd()
      assert "45677003898003" == number

      {result2, _} = maybe_strip_international_prefix_and_normalize(number, "00[39]")
      assert result2 == CountryCodeSource.from_default_country()
    end

    test "MaybeStripInternationalPrefix 2" do
      {result, number} = maybe_strip_international_prefix_and_normalize("00945677003898003", "00[39]")

      assert result == CountryCodeSource.from_number_with_idd()
      assert "45677003898003" == number
    end

    test "MaybeStripInternationalPrefix 3" do
      {result, number} = maybe_strip_international_prefix_and_normalize("00 9 45677003898003", "00[39]")

      assert result == CountryCodeSource.from_number_with_idd()
      assert "45677003898003" == number

      {result2, _} = maybe_strip_international_prefix_and_normalize(number, "00[39]")
      assert result2 == CountryCodeSource.from_default_country()
    end

    test "MaybeStripInternationalPrefix 4" do
      {result, number} = maybe_strip_international_prefix_and_normalize("+45677003898003", "00[39]")

      assert result == CountryCodeSource.from_number_with_plus_sign()
      assert "45677003898003" == number
    end

    test "MaybeStripInternationalPrefix 5" do
      {result, number} = maybe_strip_international_prefix_and_normalize("0090112-3123", "00[39]")

      assert result == CountryCodeSource.from_default_country()
      assert "00901123123" == number
    end

    test "MaybeStripInternationalPrefix 6" do
      {result, _} = maybe_strip_international_prefix_and_normalize("009 0-112-3123", "00[39]")

      assert result == CountryCodeSource.from_default_country()
    end
  end

  describe ".maybe_extract_country_code/3" do
    test "MaybeExtractCountryCode 1" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, number, phone_number} = maybe_extract_country_code("011112-3456789", metadata, true)

      assert result
      assert 1 == phone_number.country_code
      assert "123456789" = number
      assert CountryCodeSource.from_number_with_idd() == phone_number.country_code_source
    end

    test "MaybeExtractCountryCode 2" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("+6423456789", metadata, true)

      assert result
      assert 64 == phone_number.country_code
      assert CountryCodeSource.from_number_with_plus_sign() == phone_number.country_code_source
    end

    test "MaybeExtractCountryCode 3" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("+80012345678", metadata, true)

      assert result
      assert 800 == phone_number.country_code
      assert CountryCodeSource.from_number_with_plus_sign() == phone_number.country_code_source
    end

    test "MaybeExtractCountryCode 4" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("2345-6789", metadata, true)

      assert result
      assert 0 == phone_number.country_code
      assert CountryCodeSource.from_default_country() == phone_number.country_code_source
    end

    test "MaybeExtractCountryCode 5" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, message} = maybe_extract_country_code("0119991123456789", metadata, true)

      refute result
      assert message == ErrorMessages.invalid_country_code()
    end

    test "MaybeExtractCountryCode 6" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("(1 610) 619 4466", metadata, true)

      assert result
      assert 1 = phone_number.country_code

      assert CountryCodeSource.from_number_without_plus_sign() ==
               phone_number.country_code_source
    end

    test "MaybeExtractCountryCode 7" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("(1 610) 619 4466", metadata, false)

      assert result
      assert 1 = phone_number.country_code
      assert is_nil(phone_number.country_code_source)
    end

    test "MaybeExtractCountryCode 8" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("(1 610) 619 446", metadata, false)

      assert result
      assert 0 = phone_number.country_code
      assert is_nil(phone_number.country_code_source)
    end

    test "MaybeExtractCountryCode 9" do
      metadata = Metadata.get_for_region_code(RegionCodeFixture.us())
      {result, _, phone_number} = maybe_extract_country_code("(1 610) 619", metadata, true)

      assert result
      assert 0 = phone_number.country_code
      assert CountryCodeSource.from_default_country() == phone_number.country_code_source
    end
  end

  describe ".truncate_too_long_number/1" do
    test "TruncateTooLongNumber" do
      assert {true, PhoneNumberFixture.gb_toll_free()} == truncate_too_long_number(PhoneNumberFixture.gb_toll_free_too_long())

      assert {true, PhoneNumberFixture.it_number2()} == truncate_too_long_number(PhoneNumberFixture.it_number2_too_long())

      assert {true, PhoneNumberFixture.us_number()} == truncate_too_long_number(PhoneNumberFixture.us_long_number())

      assert {true, PhoneNumberFixture.international_toll_free()} == truncate_too_long_number(PhoneNumberFixture.international_toll_free_too_long())

      assert {true, PhoneNumberFixture.gb_toll_free()} == truncate_too_long_number(PhoneNumberFixture.gb_toll_free())

      assert {false, PhoneNumberFixture.us_invalid_prefix()} == truncate_too_long_number(PhoneNumberFixture.us_invalid_prefix())

      assert {false, PhoneNumberFixture.us_short_number()} == truncate_too_long_number(PhoneNumberFixture.us_short_number())
    end
  end
end

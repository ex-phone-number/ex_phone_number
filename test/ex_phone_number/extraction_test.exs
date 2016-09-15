defmodule ExPhoneNumber.ExtractionTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Extraction
  import ExPhoneNumber.Extraction
  alias ExPhoneNumber.Metadata
  alias ExPhoneNumber.Constants.CountryCodeSource
  alias ExPhoneNumber.Constants.ErrorMessages

  describe ".extract_possible_number/1" do
    context "removes preceding funky punctuation and letters" do
      it "should return the correct value" do
        assert "0800-345-600" == extract_possible_number("Tel:0800-345-600")
        assert "0800 FOR PIZZA" == extract_possible_number("Tel:0800 FOR PIZZA")
      end

      it "should not remove plus sign" do
        assert "+800-345-600" == extract_possible_number("Tel:+800-345-600")
      end

      it "should recognise wide digits as possible start values" do
        assert "\uFF10\uFF12\uFF13" == extract_possible_number("\uFF10\uFF12\uFF13")
      end

      it "should remove leading dashes" do
        assert "\uFF11\uFF12\uFF13" == extract_possible_number("Num-\uFF11\uFF12\uFF13")
      end

      it "should remove leading parenthesis" do
        assert "650) 253-0000" == extract_possible_number("(650) 253-0000")
      end
    end

    context "number not found" do
      it "should return empty string" do
        assert "" == extract_possible_number("Num-....")
      end
    end

    context "removes trailing characters" do
      it "should remove trailing non-alpha-numeric chars" do
        assert "650) 253-0000" == extract_possible_number("(650) 253-0000..- ..")
        assert "650) 253-0000" == extract_possible_number("(650) 253-0000.")
      end

      it "should remove trailing RTL char" do
        assert "650) 253-0000" == extract_possible_number("(650) 253-0000\u200F")
      end
    end
  end

  describe ".maybe_strip_national_prefix_and_carrier_code/2" do
    context "national prefix" do
      setup do
        metadata = %Metadata.PhoneMetadata{
          national_prefix_for_parsing: "34",
          general: %Metadata.PhoneNumberDescription{
            national_number_pattern: ~r/\d{4,8}/
          }
        }
        {:ok, metadata: metadata}
      end

      it "should strip national prefix", state do
        {result, _, number} = maybe_strip_national_prefix_and_carrier_code("34356778", state[:metadata])
        assert result
        assert "356778" == number
      end

      it "should strip national prefix only once", state do
        {_, _, number} = maybe_strip_national_prefix_and_carrier_code("34356778", state[:metadata])
        {result, _, number} = maybe_strip_national_prefix_and_carrier_code(number, state[:metadata])
        refute result
        assert "356778" == number
      end

      it "should not strip if national prefix is empty", state do
        metadata = %{state[:metadata] | national_prefix_for_parsing: nil}
        {result, _, number} = maybe_strip_national_prefix_and_carrier_code("34356778", metadata)
        refute result
        assert "34356778" == number
      end

      it "should not strip if does not match national rule", state do
        metadata = %{state[:metadata] | national_prefix_for_parsing: "3"}
        {result, _, number} = maybe_strip_national_prefix_and_carrier_code("3123", metadata)
        refute result
        assert "3123" == number
      end
    end

    context "carrier code" do
      it "should strip carrier code and national prefix" do
        metadata = %Metadata.PhoneMetadata{
          national_prefix_for_parsing: "0(81)?",
          general: %Metadata.PhoneNumberDescription{
            national_number_pattern: ~r/\d{4,8}/
          }
        }
        {result, carrier_code, number} = maybe_strip_national_prefix_and_carrier_code("08122123456", metadata)
        assert result
        assert "81"       == carrier_code
        assert "22123456" == number
      end
    end

    context "tranform rule" do
      it "should transform number" do
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
  end

  describe ".maybe_strip_international_prefix_and_normalize/2" do
    context "case 1" do
      it "should strip international prefix" do
        {result, number} = maybe_strip_international_prefix_and_normalize("0034567700-3898003", "00[39]")
        assert result == CountryCodeSource.from_number_with_idd
        assert "45677003898003" == number
      end

      it "should return correct CountryCodeSource" do
        {_, number} = maybe_strip_international_prefix_and_normalize("0034567700-3898003", "00[39]")
        {result, _} = maybe_strip_international_prefix_and_normalize(number, "00[39]")
        assert result == CountryCodeSource.from_default_country
      end
    end

    context "case 2" do
      it "should strip international prefix" do
        {result, number} = maybe_strip_international_prefix_and_normalize("00945677003898003", "00[39]")
        assert result == CountryCodeSource.from_number_with_idd
        assert "45677003898003" == number
      end

      it "should strip international prefix when is broken up by spaces" do
        {result, number} = maybe_strip_international_prefix_and_normalize("00 9 45677003898003", "00[39]")
        assert result == CountryCodeSource.from_number_with_idd
        assert "45677003898003" == number
      end

      it "should return correct CountryCodeSource" do
        {_, number} = maybe_strip_international_prefix_and_normalize("00 9 45677003898003", "00[39]")
        {result, _} = maybe_strip_international_prefix_and_normalize(number, "00[39]")
        assert result == CountryCodeSource.from_default_country
      end
    end

    context "case 3" do
      it "should strip international prefix when contains leading plus sign" do
        {result, number} = maybe_strip_international_prefix_and_normalize("+45677003898003", "00[39]")
        assert result == CountryCodeSource.from_number_with_plus_sign
        assert "45677003898003" == number
      end
    end

    context "number contains leading zero" do
      it "should not strip leading zero" do
        {result, number} = maybe_strip_international_prefix_and_normalize("0090112-3123", "00[39]")
        assert result == CountryCodeSource.from_default_country
        assert "00901123123" == number
      end

      it "should not strip leading zero when includes spaces" do
        {result, _} = maybe_strip_international_prefix_and_normalize("009 0-112-3123", "00[39]")
        assert result == CountryCodeSource.from_default_country
      end
    end
  end

  describe ".maybe_extract_country_code/3" do
    context "case 1" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, number, phone_number}  = maybe_extract_country_code("011112-3456789", metadata, true)
        assert result
        assert 1 == phone_number.country_code
        assert "123456789" = number
        assert CountryCodeSource.from_number_with_idd == phone_number.country_code_source
      end
    end

    context "case 2" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number}  = maybe_extract_country_code("+6423456789", metadata, true)
        assert result
        assert 64 == phone_number.country_code
        assert CountryCodeSource.from_number_with_plus_sign == phone_number.country_code_source
      end
    end

    context "case 3" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number}  = maybe_extract_country_code("+80012345678", metadata, true)
        assert result
        assert 800 == phone_number.country_code
        assert CountryCodeSource.from_number_with_plus_sign == phone_number.country_code_source
      end
    end

    context "case 4" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number}  = maybe_extract_country_code("2345-6789", metadata, true)
        assert result
        assert 0 == phone_number.country_code
        assert CountryCodeSource.from_default_country == phone_number.country_code_source
      end
    end

    context "case 5" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, message}  = maybe_extract_country_code("0119991123456789", metadata, true)
        refute result
        assert message == ErrorMessages.invalid_country_code
      end
    end

    context "case 6" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number} = maybe_extract_country_code("(1 610) 619 4466", metadata, true)
        assert result
        assert 1 = phone_number.country_code
        assert CountryCodeSource.from_number_without_plus_sign == phone_number.country_code_source
      end
    end

    context "case 7" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number} = maybe_extract_country_code("(1 610) 619 4466", metadata, false)
        assert result
        assert 1 = phone_number.country_code
        assert is_nil(phone_number.country_code_source)
      end
    end

    context "case 8" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number} = maybe_extract_country_code("(1 610) 619 446", metadata, false)
        assert result
        assert 0 = phone_number.country_code
        assert is_nil(phone_number.country_code_source)
      end
    end

    context "case 9" do
      it "should return correct values" do
        metadata = Metadata.get_for_region_code(RegionCodeFixture.us)
        {result, _, phone_number} = maybe_extract_country_code("(1 610) 619", metadata, true)
        assert result
        assert 0 = phone_number.country_code
        assert CountryCodeSource.from_default_country == phone_number.country_code_source
      end
    end
  end
end

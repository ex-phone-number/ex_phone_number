defmodule ExPhoneNumber.MetadataTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Metadata
  import ExPhoneNumber.Metadata
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias PhoneNumberFixture
  alias RegionCodeFixture

  describe ".get_for_region_code/1" do
    context "US region_code" do
      setup do
        {:ok, us_metadata: get_for_region_code(RegionCodeFixture.us)}
      end

      it "returns valid id", state do
        assert RegionCodeFixture.us == state[:us_metadata].id
      end

      it "returns valid country_code", state do
        assert 1 == state[:us_metadata].country_code
      end

      it "returns valid international_prefix", state do
        assert "011" == state[:us_metadata].international_prefix
      end

      it "returns valid has_national_prefix?", state do
        assert PhoneMetadata.has_national_prefix?(state[:us_metadata])
      end

      it "returns valid number_format length", state do
        assert 2 == length(state[:us_metadata].number_format)
      end

      it "returns valid number_format(1).pattern", state do
        assert ~r/(\d{3})(\d{3})(\d{4})/ == Enum.at(state[:us_metadata].number_format, 1).pattern
      end

      it "returns valid number_format(1).format", state do
        assert "\\g{1} \\g{2} \\g{3}" == Enum.at(state[:us_metadata].number_format, 1).format
      end

      it "returns valid general.national_number_pattern", state do
        assert ~r/[13-689]\d{9}|2[0-35-9]\d{8}/ == state[:us_metadata].general.national_number_pattern
      end

      it "returns valid general.possible_number_pattern", state do
        assert ~r/\d{7}(?:\d{3})?/ == state[:us_metadata].general.possible_number_pattern
      end

      it "returns valid fixed_line", state do
        assert state[:us_metadata].general == state[:us_metadata].fixed_line
      end

      it "returns valid toll_free.possible_number_pattern", state do
        assert ~r/\d{10}/ == state[:us_metadata].toll_free.possible_number_pattern
      end

      it "returns valid premium_rate.national_number_pattern", state do
        assert ~r/900\d{7}/ == state[:us_metadata].premium_rate.national_number_pattern
      end

      it "returns valid shared_cost.national_number_pattern", state do
        assert Values.description_default_pattern == state[:us_metadata].shared_cost.national_number_pattern
      end

      it "returns valid shared_cost.possible_number_pattern", state do
        assert Values.description_default_pattern == state[:us_metadata].shared_cost.possible_number_pattern
      end
    end

    context "DE region_code" do
      setup do
        {:ok, de_metadata: get_for_region_code(RegionCodeFixture.de)}
      end

      it "returns valid id", state do
        assert RegionCodeFixture.de  == state[:de_metadata].id
      end

      it "returns valid country_code", state do
        assert 49 == state[:de_metadata].country_code
      end

      it "returns valid international_prefix", state do
        assert "00" == state[:de_metadata].international_prefix
      end

      it "returns valid national_prefix", state do
        assert "0" == state[:de_metadata].national_prefix
      end

      it "returns valid number_format length", state do
        assert 6 == length(state[:de_metadata].number_format)
      end

      it "returns valid number_format(5).leading_digits_pattern length", state do
        assert 1 == length(Enum.at(state[:de_metadata].number_format, 5).leading_digits_pattern)
      end

      it "returns valid number_format(5).leading_digits_pattern(0)", state do
        assert ~r/900/ == Enum.at(Enum.at(state[:de_metadata].number_format, 5).leading_digits_pattern, 0)
      end

      it "returns valid number_format(5).pattern", state do
        assert ~r/(\d{3})(\d{3,4})(\d{4})/ == Enum.at(state[:de_metadata].number_format, 5).pattern
      end

      it "returns valid number_format(5).format", state do
        assert "\\g{1} \\g{2} \\g{3}" ==  Enum.at(state[:de_metadata].number_format, 5).format
      end

      it "returns valid fixed_line.national_number_pattern", state do
        assert ~r/(?:[24-6]\d{2}|3[03-9]\d|[789](?:[1-9]\d|0[2-9]))\d{1,8}/ == state[:de_metadata].fixed_line.national_number_pattern
      end

      it "returns valid fixed_line.possible_number_pattern", state do
        assert ~r/\d{2,14}/ == state[:de_metadata].fixed_line.possible_number_pattern
      end

      it "returns valid fixed_line.example_number", state do
        assert "30123456" == state[:de_metadata].fixed_line.example_number
      end

      it "returns valid toll_free.possible_number_pattern", state do
        assert ~r/\d{10}/ == state[:de_metadata].toll_free.possible_number_pattern
      end

      it "returns valid premium_rate.national_number_pattern", state do
        assert ~r/900([135]\d{6}|9\d{7})/ == state[:de_metadata].premium_rate.national_number_pattern
      end
    end

    context "AR region_code" do
      setup do
        {:ok, ar_metadata: get_for_region_code(RegionCodeFixture.ar)}
      end

      it "returns valid id", state do
        assert RegionCodeFixture.ar == state[:ar_metadata].id
      end

      it "returns valid country_code", state do
        assert 54 == state[:ar_metadata].country_code
      end

      it "returns valid international_prefix", state do
        assert "00" == state[:ar_metadata].international_prefix
      end

      it "returns valid national_prefix", state do
        assert "0" == state[:ar_metadata].national_prefix
      end

      it "returns valid national_prefix_for_parsing", state do
        assert "0(?:(11|343|3715)15)?" == state[:ar_metadata].national_prefix_for_parsing
      end

      it "returns valid national_prefix_transform_rule", state do
        assert "9\\g{1}" == state[:ar_metadata].national_prefix_transform_rule
      end

      it "returns valid number_format(2).format", state do
        assert "\\g{2} 15 \\g{3}-\\g{4}" == Enum.at(state[:ar_metadata].number_format, 2).format
      end

      it "returns valid number_format(3).pattern", state do
        assert ~r/(9)(\d{4})(\d{2})(\d{4})/ == Enum.at(state[:ar_metadata].number_format, 3).pattern
      end

      it "returns valid intl_number_format(3).pattern", state do
        assert ~r/(9)(\d{4})(\d{2})(\d{4})/ == Enum.at(state[:ar_metadata].intl_number_format, 3).pattern
      end

      it "returns valid intl_number_format(3).format", state do
        assert "\\g{1} \\g{2} \\g{3} \\g{4}" == Enum.at(state[:ar_metadata].intl_number_format, 3).format
      end
    end
  end

  describe ".get_for_non_geographical_region/1" do
    context "800 calling code" do
      setup do
        {:ok, un001_metadata: get_for_non_geographical_region(800)}
      end

      it "returns valid id", state do
        assert RegionCodeFixture.un001 == state[:un001_metadata].id
      end

      it "returns valid country_code", state do
        assert 800 == state[:un001_metadata].country_code
      end

      it "returns valid number_format(0).format", state do
        assert "\\g{1} \\g{2}" == Enum.at(state[:un001_metadata].number_format, 0).format
      end

      it "returns valid number_format(0).pattern", state do
        assert ~r/(\d{4})(\d{4})/ == Enum.at(state[:un001_metadata].number_format, 0).pattern
      end

      it "returns valid general.example_number", state do
        assert "12345678" == state[:un001_metadata].general.example_number
      end

      it "returns valid toll_free.example_number", state do
        assert "12345678" == state[:un001_metadata].toll_free.example_number
      end
    end
  end

  describe ".get_supported_regions/1" do
    context "get a list of supported regions" do
      it "should contain at least one element" do
        assert 0 < length(get_supported_regions())
      end
    end
  end

  describe ".is_supported_region?/1" do
    context "US" do
      it "returns true" do
        assert is_supported_region?(RegionCodeFixture.us)
      end
    end

    context "001" do
      it "returns false" do
        refute is_supported_region?(RegionCodeFixture.un001)
      end

      it "returns false for calling code" do
        refute Enum.any?(get_supported_regions(), fn(region_code) -> region_code == "800" end)
      end
    end
  end

  describe ".get_supported_global_network_calling_codes/1" do
    context "get a list of supported global network calling codes" do
      it "contains at least one element" do
        assert 0 < length(get_supported_global_network_calling_codes())
      end
    end

    context "test all the calling codes" do
      it "contains all the calling codes" do
        assert Enum.all?(get_supported_global_network_calling_codes(), fn(calling_code) -> get_region_code_for_country_code(calling_code) == RegionCodeFixture.un001 end)
      end
    end
  end

  describe ".is_supported_global_network_calling_code?/1" do
    context "US" do
      it "returns false" do
        refute is_supported_global_network_calling_code?(1)
      end
    end

    context "800" do
      it "returns true" do
        assert is_supported_global_network_calling_code?(800)
      end
    end
  end

  describe ".get_region_code_for_country_code/1" do
    context "1" do
      it "returns correct value" do
        assert RegionCodeFixture.us == get_region_code_for_country_code(1)
      end
    end

    context "44" do
      it "returns correct value" do
        assert RegionCodeFixture.gb == get_region_code_for_country_code(44)
      end
    end

    context "49" do
      it "returns correct value" do
        assert RegionCodeFixture.de == get_region_code_for_country_code(49)
      end
    end

    context "800" do
      it "returns correct value" do
        assert RegionCodeFixture.un001 == get_region_code_for_country_code(800)
      end
    end

    context "979" do
      it "returns correct value" do
        assert RegionCodeFixture.un001 == get_region_code_for_country_code(979)
      end
    end
  end

  describe ".get_region_codes_for_country_code/1" do
    context "1" do
      it "should contains US BS" do
        list = get_region_codes_for_country_code(1)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.us))
        assert Enum.any?(list, &(&1 == RegionCodeFixture.bs))
      end
    end

    context "44" do
      it "should contains GB" do
        list = get_region_codes_for_country_code(44)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.gb))
      end
    end

    context "49" do
      it "should contains DE" do
        list = get_region_codes_for_country_code(49)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.de))
      end
    end

    context "800" do
      it "should contains 001" do
        list = get_region_codes_for_country_code(800)
        assert Enum.any?(list, &(&1 == RegionCodeFixture.un001))
      end
    end

    context "-1" do
      it "should be empty" do
        assert 0 == length(get_region_codes_for_country_code(-1))
      end
    end
  end

  describe ".get_country_code_for_region_code/1" do
    context "US" do
      it "returns correct value" do
        assert 1 == get_country_code_for_region_code RegionCodeFixture.us
      end
    end

    context "NZ" do
      it "returns correct value" do
        assert 64 == get_country_code_for_region_code RegionCodeFixture.nz
      end
    end

    context "nil" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code nil
      end
    end

    context "ZZ" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code RegionCodeFixture.zz
      end
    end

    context "001" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code RegionCodeFixture.un001
      end
    end

    context "CS" do
      it "returns correct value" do
        assert 0 == get_country_code_for_region_code "CS"
      end
    end
  end

  describe ".get_region_code_for_number/1" do
    context "BS" do
      it "return correct value" do
        assert RegionCodeFixture.bs == get_region_code_for_number(PhoneNumberFixture.bs_number)
      end
    end

    context "YT" do
      it "return correct value" do
        assert RegionCodeFixture.yt == get_region_code_for_number(PhoneNumberFixture.re_number_invalid)
      end
    end

    context "US" do
      it "return correct value" do
        assert RegionCodeFixture.us == get_region_code_for_number(PhoneNumberFixture.us_number)
      end
    end

    context "GB" do
      it "return correct value" do
        assert RegionCodeFixture.gb == get_region_code_for_number(PhoneNumberFixture.gb_mobile)
      end
    end

    context "001" do
      it "return correct value for International Toll Free" do
        assert RegionCodeFixture.un001 == get_region_code_for_number(PhoneNumberFixture.international_toll_free)
      end

      it "return correct value for Universal Premium Rate" do
        assert RegionCodeFixture.un001 == get_region_code_for_number(PhoneNumberFixture.universal_premium_rate)
      end
    end
  end

  describe ".is_leading_zero_possible?/1" do
    context "Italy" do
      it "returns true" do
        assert is_leading_zero_possible?(39)
      end
    end

    context "USA" do
      it "returns false" do
        refute is_leading_zero_possible?(1)
      end
    end

    context "International Toll Free" do
      it "returns true" do
        assert is_leading_zero_possible?(800)
      end
    end

    context "Internatioal Premium Rate" do
      it "returns false" do
        refute is_leading_zero_possible?(979)
      end
    end

    context "Invalid" do
      it "returns false" do
        refute is_leading_zero_possible?(888)
      end
    end
  end

  describe ".get_ndd_prefix_for_region_code/2" do
    context "US, false" do
      it "returns the correct value" do
        assert "1" == get_ndd_prefix_for_region_code(RegionCodeFixture.us, false)
      end
    end

    context "BS, false" do
      it "returns the correct value" do
        assert "1" == get_ndd_prefix_for_region_code(RegionCodeFixture.bs, false)
      end
    end

    context "NZ, false" do
      it "returns the correct value" do
        assert "0" == get_ndd_prefix_for_region_code(RegionCodeFixture.nz, false)
      end
    end

    context "A0, false" do
      it "returns the correct value" do
        assert "0~0" == get_ndd_prefix_for_region_code(RegionCodeFixture.ao, false)
      end
    end

    context "A0, true" do
      it "returns the correct value" do
        assert "00" == get_ndd_prefix_for_region_code(RegionCodeFixture.ao, true)
      end
    end

    context "empty, false" do
      it "returns the correct value" do
        refute get_ndd_prefix_for_region_code("", false)
      end
    end

    context "ZZ, false" do
      it "returns the correct value" do
        refute get_ndd_prefix_for_region_code(RegionCodeFixture.zz, false)
      end
    end

    context "UN001, false" do
      it "returns the correct value" do
        refute get_ndd_prefix_for_region_code(RegionCodeFixture.un001, false)
      end
    end

    context "CS, false" do
      it "returns the correct value" do
        refute get_ndd_prefix_for_region_code(RegionCodeFixture.cs, false)
      end
    end
  end

  describe ".is_nanpa_country?/1" do
    context "US" do
      it "returns true" do
        assert is_nanpa_country?(RegionCodeFixture.us)
      end
    end

    context "BS" do
      it "returns true" do
        assert is_nanpa_country?(RegionCodeFixture.bs)
      end
    end

    context "DE" do
      it "returns false" do
        refute is_nanpa_country?(RegionCodeFixture.de)
      end
    end

    context "ZZ" do
      it "returns false" do
        refute is_nanpa_country?(RegionCodeFixture.zz)
      end
    end

    context "UN001" do
      it "returns false" do
        refute is_nanpa_country?(RegionCodeFixture.un001)
      end
    end

    context "nil" do
      it "returns false" do
        refute is_nanpa_country?(nil)
      end
    end
  end
end

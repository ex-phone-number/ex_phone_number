defmodule ExPhoneNumber.MetadataTest do
  use ExUnit.Case, async: true

  doctest ExPhoneNumber.Metadata

  import ExPhoneNumber.Metadata

  alias ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.{PhoneNumberFixture, RegionCodeFixture}

  setup_all do
    [
      us_metadata: get_for_region_code(RegionCodeFixture.us()),
      de_metadata: get_for_region_code(RegionCodeFixture.de()),
      ar_metadata: get_for_region_code(RegionCodeFixture.ar()),
      un001_metadata: get_for_non_geographical_region(800)
    ]
  end

  describe "get_for_region_code/1" do
    test "GetInstanceLoadUSMetadata", %{us_metadata: metadata} do
      assert RegionCodeFixture.us() == metadata.id
      assert 1 == metadata.country_code
      assert "011" == metadata.international_prefix
      assert PhoneMetadata.has_national_prefix?(metadata)
      assert 2 == length(metadata.number_format)
      assert ~r/(\d{3})(\d{3})(\d{4})/ == Enum.at(metadata.number_format, 1).pattern
      assert "\\g{1} \\g{2} \\g{3}" == Enum.at(metadata.number_format, 1).format
      assert ~r/[13-689]\d{9}|2[0-35-9]\d{8}/ == metadata.general.national_number_pattern
      assert ~r/[13-689]\d{9}|2[0-35-9]\d{8}/ == metadata.fixed_line.national_number_pattern
      assert ~r/900\d{7}/ == metadata.premium_rate.national_number_pattern
      assert is_nil(metadata.shared_cost.national_number_pattern)
    end

    test "GetInstanceLoadDEMetadata", %{de_metadata: metadata} do
      assert RegionCodeFixture.de() == metadata.id
      assert 49 == metadata.country_code
      assert "00" == metadata.international_prefix
      assert "0" == metadata.national_prefix
      assert 6 == length(metadata.number_format)
      assert 1 == length(Enum.at(metadata.number_format, 5).leading_digits_pattern)
      assert ~r/900/ == Enum.at(Enum.at(metadata.number_format, 5).leading_digits_pattern, 0)
      assert ~r/(\d{3})(\d{3,4})(\d{4})/ == Enum.at(metadata.number_format, 5).pattern
      assert "\\g{1} \\g{2} \\g{3}" == Enum.at(metadata.number_format, 5).format
      assert ~r/(?:[24-6]\d{2}|3[03-9]\d|[789](?:0[2-9]|[1-9]\d))\d{1,8}/ == metadata.fixed_line.national_number_pattern
      assert "30123456" == metadata.fixed_line.example_number
      assert ~r/900([135]\d{6}|9\d{7})/ == metadata.premium_rate.national_number_pattern
    end

    test "GetInstanceLoadARMetadata", %{ar_metadata: metadata} do
      assert RegionCodeFixture.ar() == metadata.id
      assert 54 == metadata.country_code
      assert "00" == metadata.international_prefix
      assert "0" == metadata.national_prefix
      assert "0(?:(11|343|3715)15)?" == metadata.national_prefix_for_parsing
      assert "9\\g{1}" == metadata.national_prefix_transform_rule
      assert "\\g{2} 15 \\g{3}-\\g{4}" == Enum.at(metadata.number_format, 2).format
      assert ~r/(\d)(\d{4})(\d{2})(\d{4})/ == Enum.at(metadata.number_format, 3).pattern
      assert ~r/(\d)(\d{4})(\d{2})(\d{4})/ == Enum.at(metadata.intl_number_format, 3).pattern
      assert "\\g{1} \\g{2} \\g{3} \\g{4}" == Enum.at(metadata.intl_number_format, 3).format
    end

    test "US region_code returns valid general.possible_lengths", %{us_metadata: metadata} do
      assert [7, 10] == metadata.general.possible_lengths
    end

    test "US region_code returns valid toll_free.possible_lengths", %{us_metadata: metadata} do
      assert [10] == metadata.toll_free.possible_lengths
    end

    test "US region_code returns valid shared_cost.national_number_pattern", %{us_metadata: metadata} do
      assert Values.description_default_pattern() == metadata.shared_cost.national_number_pattern
    end

    test "US region_code returns valid shared_cost.possible_lengths", %{us_metadata: metadata} do
      assert Values.description_default_length() == metadata.shared_cost.possible_lengths
    end

    test "DE region_code returns valid fixed_line.possible_lengths", %{de_metadata: metadata} do
      assert Enum.to_list(2..11) == metadata.fixed_line.possible_lengths
    end

    test "DE region_code returns valid toll_free.possible_lengths", %{de_metadata: metadata} do
      assert [10] == metadata.toll_free.possible_lengths
    end
  end

  describe "get_for_non_geographical_region/1" do
    test "GetInstanceLoadInternationalTollFreeMetadata", %{un001_metadata: metadata} do
      assert RegionCodeFixture.un001() == metadata.id
      assert 800 == metadata.country_code
      assert "\\g{1} \\g{2}" == Enum.at(metadata.number_format, 0).format
      assert ~r/(\d{4})(\d{4})/ == Enum.at(metadata.number_format, 0).pattern
      assert Enum.empty?(metadata.general.national_possible_lengths)
      assert 1 == length(metadata.general.possible_lengths)
      assert "12345678" == metadata.toll_free.example_number
    end
  end

  describe "get_supported_regions/1" do
    test "GetSupportedRegions" do
      supported_regions = get_supported_regions()

      assert length(supported_regions) > 0
      assert Enum.find(supported_regions, fn region_code -> region_code == RegionCodeFixture.us() end)
      refute Enum.find(supported_regions, fn region_code -> region_code == RegionCodeFixture.un001() end)
      refute Enum.any?(supported_regions, fn region_code -> region_code == "800" end)
    end
  end

  describe "is_supported_region?/1" do
    test "GetSupportedRegions" do
      assert is_supported_region?(RegionCodeFixture.us())
      refute is_supported_region?(RegionCodeFixture.un001())
    end
  end

  describe "get_supported_global_network_calling_codes/1" do
    test "GetSupportedGlobalNetworkCallingCodes" do
      supported_global_network_calling_codes = get_supported_global_network_calling_codes()

      assert length(supported_global_network_calling_codes) > 0

      refute Enum.any?(supported_global_network_calling_codes, fn calling_code ->
               get_region_code_for_country_code(calling_code) == RegionCodeFixture.us()
             end)

      assert Enum.any?(supported_global_network_calling_codes, fn calling_code ->
               calling_code == 800
             end)

      assert Enum.all?(supported_global_network_calling_codes, fn calling_code ->
               get_region_code_for_country_code(calling_code) == RegionCodeFixture.un001()
             end)
    end

    test "GetSupportedCallingCodes" do
      assert Enum.member?(get_supported_global_network_calling_codes(), 979)
    end
  end

  describe "is_supported_global_network_calling_code?/1" do
    test "US returns false" do
      refute is_supported_global_network_calling_code?(1)
    end

    test "800 returns true" do
      assert is_supported_global_network_calling_code?(800)
    end
  end

  describe "get_supported_calling_codes/0" do
    test "GetSupportedCallingCodes" do
      supported_calling_codes = get_supported_calling_codes()

      assert length(supported_calling_codes) > 0

      assert Enum.all?(supported_calling_codes, fn calling_code ->
               calling_code > 0 and RegionCodeFixture.zz() != get_region_code_for_country_code(calling_code)
             end)

      assert length(supported_calling_codes) > length(get_supported_global_network_calling_codes())
    end
  end

  describe "get_supported_types_for_region/1" do
    test "GetSupportedTypesForRegion" do
      br_types = get_supported_types_for_region(RegionCodeFixture.br())

      assert Enum.member?(br_types, PhoneNumberTypes.fixed_line())
      refute Enum.member?(br_types, PhoneNumberTypes.mobile())
      refute Enum.member?(br_types, PhoneNumberTypes.unknown())

      us_types = get_supported_types_for_region(RegionCodeFixture.us())

      assert Enum.member?(us_types, PhoneNumberTypes.fixed_line())
      assert Enum.member?(us_types, PhoneNumberTypes.mobile())
      refute Enum.member?(us_types, PhoneNumberTypes.fixed_line_or_mobile())

      zz_types = get_supported_types_for_region(RegionCodeFixture.zz())
      assert Enum.empty?(zz_types)
    end
  end

  describe "get_supported_types_for_non_geo_entity/1" do
    test "GetSupportedTypesForNonGeoEntity" do
      types_999 = get_supported_types_for_non_geo_entity(999)
      assert Enum.empty?(types_999)

      types_979 = get_supported_types_for_non_geo_entity(979)
      assert Enum.member?(types_979, PhoneNumberTypes.premium_rate())
      refute Enum.member?(types_979, PhoneNumberTypes.mobile())
      refute Enum.member?(types_979, PhoneNumberTypes.unknown())
    end
  end

  describe "get_region_code_for_country_code/1" do
    test "GetRegionCodeForCountryCode" do
      assert RegionCodeFixture.us() == get_region_code_for_country_code(1)
      assert RegionCodeFixture.gb() == get_region_code_for_country_code(44)
      assert RegionCodeFixture.de() == get_region_code_for_country_code(49)
      assert RegionCodeFixture.un001() == get_region_code_for_country_code(800)
      assert RegionCodeFixture.un001() == get_region_code_for_country_code(979)
    end
  end

  describe "get_region_code_for_number/1" do
    test "IsValidForRegion" do
      assert RegionCodeFixture.yt() ==
               get_region_code_for_number(PhoneNumberFixture.re_number_invalid())
    end

    test "GetRegionCodeForNumber" do
      assert RegionCodeFixture.bs() == get_region_code_for_number(PhoneNumberFixture.bs_number())
      assert RegionCodeFixture.us() == get_region_code_for_number(PhoneNumberFixture.us_number())
      assert RegionCodeFixture.gb() == get_region_code_for_number(PhoneNumberFixture.gb_mobile())
      assert RegionCodeFixture.un001() == get_region_code_for_number(PhoneNumberFixture.international_toll_free())
      assert RegionCodeFixture.un001() == get_region_code_for_number(PhoneNumberFixture.universal_premium_rate())
    end
  end

  describe "get_region_codes_for_country_code/1" do
    test "GetRegionCodesForCountryCode" do
      region_codes_for_nanpa = get_region_codes_for_country_code(1)
      assert Enum.member?(region_codes_for_nanpa, RegionCodeFixture.us())
      assert Enum.member?(region_codes_for_nanpa, RegionCodeFixture.bs())

      region_codes_gb = get_region_codes_for_country_code(44)
      assert Enum.member?(region_codes_gb, RegionCodeFixture.gb())

      region_codes_de = get_region_codes_for_country_code(49)
      assert Enum.member?(region_codes_de, RegionCodeFixture.de())

      region_codes_un001 = get_region_codes_for_country_code(800)
      assert Enum.member?(region_codes_un001, RegionCodeFixture.un001())

      assert Enum.empty?(get_region_codes_for_country_code(-1))
    end
  end

  describe "get_country_mobile_token/1" do
    test "GetCountryMobileToken" do
      assert "9" == get_country_mobile_token(get_country_code_for_region_code(RegionCodeFixture.ar()))
      assert "" == get_country_mobile_token(get_country_code_for_region_code(RegionCodeFixture.se()))
    end
  end

  describe "get_country_code_for_region_code/1" do
    test "GetCountryCodeForRegion" do
      assert 1 == get_country_code_for_region_code(RegionCodeFixture.us())
      assert 64 == get_country_code_for_region_code(RegionCodeFixture.nz())
      assert 0 == get_country_code_for_region_code(nil)
      assert 0 == get_country_code_for_region_code(RegionCodeFixture.zz())
      assert 0 == get_country_code_for_region_code(RegionCodeFixture.un001())
      assert 0 == get_country_code_for_region_code("CS")
    end
  end

  describe "get_ndd_prefix_for_region_code/2" do
    test "GetNationalDiallingPrefixForRegion" do
      assert "1" == get_ndd_prefix_for_region_code(RegionCodeFixture.us(), false)
      assert "1" == get_ndd_prefix_for_region_code(RegionCodeFixture.bs(), false)
      assert "0" == get_ndd_prefix_for_region_code(RegionCodeFixture.nz(), false)
      assert "0~0" == get_ndd_prefix_for_region_code(RegionCodeFixture.ao(), false)
      assert "00" == get_ndd_prefix_for_region_code(RegionCodeFixture.ao(), true)
      assert is_nil(get_ndd_prefix_for_region_code("", false))
      assert is_nil(get_ndd_prefix_for_region_code(RegionCodeFixture.zz(), false))
      assert is_nil(get_ndd_prefix_for_region_code(RegionCodeFixture.un001(), false))
      assert is_nil(get_ndd_prefix_for_region_code(RegionCodeFixture.cs(), false))
    end
  end

  describe "is_nanpa_country?/1" do
    test "IsNANPACountry" do
      assert is_nanpa_country?(RegionCodeFixture.us())
      assert is_nanpa_country?(RegionCodeFixture.bs())
      refute is_nanpa_country?(RegionCodeFixture.de())
      refute is_nanpa_country?(RegionCodeFixture.zz())
      refute is_nanpa_country?(RegionCodeFixture.un001())
      refute is_nanpa_country?(nil)
    end
  end
end

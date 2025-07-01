defmodule ExPhoneNumber.ValidationTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Validation
  import ExPhoneNumber.Validation
  alias ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.ValidationResults
  alias PhoneNumberFixture
  alias RegionCodeFixture

  describe ".is_possible_number?/1" do
    context "US number" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.us_number())
      end
    end

    context "US local number" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.us_local_number())
      end
    end

    context "GB number" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.gb_number())
      end
    end

    context "International Toll Free" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.international_toll_free())
      end
    end

    context "US short code" do
      it "should return true" do
        assert is_possible_number?(PhoneNumberFixture.us_short_code())
      end
    end

    context "NANPA short number" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.nanpa_short_number())
      end
    end

    context "US long number" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.us_long_number())
      end
    end

    context "GB short number" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.gb_short_number())
      end
    end

    context "International Toll Free too long" do
      it "should return false" do
        refute is_possible_number?(PhoneNumberFixture.international_toll_free_too_long())
      end
    end
  end

  describe ".is_possible_number_with_reason?/1" do
    context "US number" do
      it "should return correct value" do
        assert ValidationResults.is_possible() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.us_number())
      end
    end

    context "US local number" do
      it "should return correct value" do
        assert ValidationResults.is_possible() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.us_number())
      end
    end

    context "US long number" do
      it "should return correct value" do
        assert ValidationResults.too_long() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.us_long_number())
      end
    end

    context "Invalid country code" do
      it "should return correct value" do
        assert ValidationResults.invalid_country_code() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.unknown_country_code2())
      end
    end

    context "US short number" do
      it "should return correct value" do
        assert ValidationResults.too_short() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.nanpa_short_number())
      end
    end

    context "SG number 2" do
      it "should return correct value" do
        assert ValidationResults.is_possible() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.sg_number2())
      end
    end

    context "International Toll Free long number" do
      it "should return correct value" do
        assert ValidationResults.too_long() ==
                 is_possible_number_with_reason?(PhoneNumberFixture.international_toll_free_too_long())
      end
    end
  end

  describe ".is_viable_phone_number?" do
    context "ascii chars" do
      it "should contain at least 2 chars" do
        refute is_viable_phone_number?("1")
      end

      it "should allow only one or two digits before strange non-possible puntuaction" do
        refute is_viable_phone_number?("1+1+1")
        refute is_viable_phone_number?("80+0")
      end

      it "should allow two or more digits" do
        assert is_viable_phone_number?("00")
        assert is_viable_phone_number?("111")
      end

      it "should allow alpha numbers" do
        assert is_viable_phone_number?("0800-4-pizza")
        assert is_viable_phone_number?("0800-4-PIZZA")
      end

      it "should contain at least three digits before any alpha char" do
        refute is_viable_phone_number?("08-PIZZA")
        refute is_viable_phone_number?("8-PIZZA")
        refute is_viable_phone_number?("12. March")
      end
    end

    context "non-ascii chars" do
      it "should allow only one or two digits before strange non-possible puntuaction" do
        assert is_viable_phone_number?("1\u300034")
        refute is_viable_phone_number?("1\u30003+4")
      end

      it "should allow unicode variants of starting chars" do
        assert is_viable_phone_number?("\uFF081\uFF09\u30003456789")
      end

      it "should allow leading plus sign" do
        assert is_viable_phone_number?("+1\uFF09\u30003456789")
      end
    end
  end

  describe ".is_valid_number/1" do
    context "test US number" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.us_number())
      end
    end

    context "test IT number" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.it_number())
      end
    end

    context "test GB mobile" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.gb_mobile())
      end
    end

    context "test International Toll Free" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.international_toll_free())
      end
    end

    context "test Universal Premium Rate" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.universal_premium_rate())
      end
    end

    context "test NZ number 2" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.nz_number2())
      end
    end

    context "test invalid BS number" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.bs_number_invalid())
      end
    end

    context "test IT invalid" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.it_invalid())
      end
    end

    context "test GB invalid" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.gb_invalid())
      end
    end

    context "test DE invalid" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.de_invalid())
      end

      it "returns false #2" do
        {result, phone_number} = ExPhoneNumber.parse("+494915778961257", "DE")
        assert :ok == result
        refute is_valid_number?(phone_number)
      end
    end

    context "test NZ invalid" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.nz_invalid())
      end
    end

    context "test country code invalid" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.unknown_country_code())
      end

      it "returns false #2" do
        refute is_valid_number?(PhoneNumberFixture.unknown_country_code2())
      end
    end
  end

  describe ".is_valid_number_for_region?/2" do
    context "test BS number" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.bs_number())
      end

      it "returns true #2" do
        assert is_valid_number_for_region?(PhoneNumberFixture.bs_number(), RegionCodeFixture.bs())
      end

      it "returns false" do
        refute is_valid_number_for_region?(PhoneNumberFixture.bs_number(), RegionCodeFixture.us())
      end
    end

    context "test RE number" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.re_number())
      end

      it "returns true #2" do
        assert is_valid_number_for_region?(PhoneNumberFixture.re_number(), RegionCodeFixture.re())
      end

      it "returns false" do
        refute is_valid_number_for_region?(PhoneNumberFixture.re_number(), RegionCodeFixture.yt())
      end
    end

    context "test RE number invalid" do
      it "returns false" do
        refute is_valid_number?(PhoneNumberFixture.re_number_invalid())
      end

      it "returns false #2" do
        refute is_valid_number_for_region?(
                 PhoneNumberFixture.re_number_invalid(),
                 RegionCodeFixture.re()
               )
      end

      it "returns false #3" do
        refute is_valid_number_for_region?(
                 PhoneNumberFixture.re_number_invalid(),
                 RegionCodeFixture.yt()
               )
      end
    end

    context "test YT number" do
      it "returns true" do
        assert is_valid_number?(PhoneNumberFixture.yt_number())
      end

      it "returns true #2" do
        assert is_valid_number_for_region?(PhoneNumberFixture.yt_number(), RegionCodeFixture.yt())
      end

      it "returns false" do
        refute is_valid_number_for_region?(PhoneNumberFixture.yt_number(), RegionCodeFixture.re())
      end
    end

    context "test multi country number" do
      it "returns true" do
        assert is_valid_number_for_region?(
                 PhoneNumberFixture.re_yt_number(),
                 RegionCodeFixture.re()
               )
      end

      it "returns true #2" do
        assert is_valid_number_for_region?(
                 PhoneNumberFixture.re_yt_number(),
                 RegionCodeFixture.yt()
               )
      end
    end

    context "test International Toll Free number" do
      it "returns true" do
        assert is_valid_number_for_region?(
                 PhoneNumberFixture.international_toll_free(),
                 RegionCodeFixture.un001()
               )
      end

      it "returns false #1" do
        refute is_valid_number_for_region?(
                 PhoneNumberFixture.international_toll_free(),
                 RegionCodeFixture.us()
               )
      end

      it "returns false #2" do
        refute is_valid_number_for_region?(
                 PhoneNumberFixture.international_toll_free(),
                 RegionCodeFixture.zz()
               )
      end
    end
  end

  describe ".is_number_geographical?/1" do
    context "test BS mobile" do
      it "returns false" do
        refute is_number_geographical?(PhoneNumberFixture.bs_mobile())
      end
    end

    context "test AU number" do
      it "returns true" do
        assert is_number_geographical?(PhoneNumberFixture.au_number())
      end
    end

    context "test International Toll Free number" do
      it "returns false" do
        refute is_number_geographical?(PhoneNumberFixture.international_toll_free())
      end
    end
  end

  describe ".get_number_type/1" do
    context "test IT premium" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.it_premium()) == PhoneNumberTypes.premium_rate()
      end
    end

    context "test GB premium" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_premium()) == PhoneNumberTypes.premium_rate()
      end
    end

    context "test DE premium" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.de_premium()) == PhoneNumberTypes.premium_rate()
      end

      it "returns true #" do
        assert get_number_type(PhoneNumberFixture.de_premium2()) ==
                 PhoneNumberTypes.premium_rate()
      end
    end

    context "test Universal Premium Rate" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.universal_premium_rate()) ==
                 PhoneNumberTypes.premium_rate()
      end
    end

    context "test US toll free" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.us_tollfree2()) == PhoneNumberTypes.toll_free()
      end
    end

    context "test IT toll free" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.it_toll_free()) == PhoneNumberTypes.toll_free()
      end
    end

    context "test GB toll free" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_toll_free()) == PhoneNumberTypes.toll_free()
      end
    end

    context "test DE toll free" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.de_toll_free()) == PhoneNumberTypes.toll_free()
      end
    end

    context "test International Toll Free" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.international_toll_free()) ==
                 PhoneNumberTypes.toll_free()
      end
    end

    context "test BS mobile" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.bs_mobile()) == PhoneNumberTypes.mobile()
      end
    end

    context "test GB mobile" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_mobile()) == PhoneNumberTypes.mobile()
      end
    end

    context "test IT mobile" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.it_mobile()) == PhoneNumberTypes.mobile()
      end
    end

    context "test AR mobile" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.ar_mobile()) == PhoneNumberTypes.mobile()
      end
    end

    context "test DE mobile" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.de_mobile()) == PhoneNumberTypes.mobile()
      end
    end

    context "test BS number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.bs_number()) == PhoneNumberTypes.fixed_line()
      end
    end

    context "test IT number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.it_number()) == PhoneNumberTypes.fixed_line()
      end
    end

    context "test GB number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_number()) == PhoneNumberTypes.fixed_line()
      end
    end

    context "test DE number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.de_number()) == PhoneNumberTypes.fixed_line()
      end
    end

    context "test US number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.us_number()) ==
                 PhoneNumberTypes.fixed_line_or_mobile()
      end
    end

    context "test AR number 2" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.ar_number2()) ==
                 PhoneNumberTypes.fixed_line_or_mobile()
      end
    end

    context "test GB shared cost" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_shared_cost()) ==
                 PhoneNumberTypes.shared_cost()
      end
    end

    context "test GB voip" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_voip()) == PhoneNumberTypes.voip()
      end
    end

    context "test GB personal number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.gb_personal_number()) ==
                 PhoneNumberTypes.personal_number()
      end
    end

    context "test US local number" do
      it "returns true" do
        assert get_number_type(PhoneNumberFixture.us_local_number()) == PhoneNumberTypes.unknown()
      end
    end
  end

  describe ".validate_length" do
    context "length less or equal to Constants.Value.max_input_string_length" do
      it "returns {:ok, number}" do
        subject = "1234567890"
        assert {:ok, _} = validate_length(subject)
      end
    end

    context "length larger than Constants.Value.max_input_string_length" do
      it "returns {:error, message}" do
        subject =
          "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x"

        assert {:error, _} = validate_length(subject)
      end
    end
  end
end

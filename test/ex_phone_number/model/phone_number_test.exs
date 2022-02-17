defmodule ExPhoneNumber.Model.PhoneNumberTest do
  use ExUnit.Case, async: true

  doctest ExPhoneNumber.Model.PhoneNumber

  import ExPhoneNumber.PhoneNumberFixture
  import ExPhoneNumber.Model.PhoneNumber

  describe ".get_national_significant_number/1" do
    test "GetNationalSignificantNumber" do
      assert "6502530000" == get_national_significant_number(us_number())
      assert "345678901" == get_national_significant_number(it_mobile())
      assert "0236618300" == get_national_significant_number(it_number())
      assert "12345678" == get_national_significant_number(international_toll_free())
      assert "" == get_national_significant_number(empty_number())
    end

    test "GetNationalSignificantNumber_ManyLeadingZeros" do
      assert "00650" == get_national_significant_number(too_many_zeros1())
      assert "650" == get_national_significant_number(too_many_zeros2())
    end
  end
end

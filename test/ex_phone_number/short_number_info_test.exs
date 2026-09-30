defmodule ExPhoneNumber.ShortNumberInfoTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.ShortNumberInfo
  import ExPhoneNumber.ShortNumberInfo
  alias ExPhoneNumber.Model.PhoneNumber

  # Cases ported from libphonenumber's ShortNumberInfoTest.

  describe ".is_possible_short_number?" do
    it "accepts a possible FR short number" do
      assert is_possible_short_number?(%PhoneNumber{country_code: 33, national_number: 123_456})
      {:ok, number} = ExPhoneNumber.parse("123456", "FR")
      assert is_possible_short_number?(number, "FR")
    end

    it "rejects an impossible FR short number" do
      refute is_possible_short_number?(%PhoneNumber{country_code: 33, national_number: 9})
    end

    it "checks every region sharing the country code (GB and GG share 44)" do
      assert is_possible_short_number?(%PhoneNumber{country_code: 44, national_number: 11_001})
    end
  end

  describe ".is_valid_short_number?" do
    it "accepts a valid FR short number" do
      assert is_valid_short_number?(%PhoneNumber{country_code: 33, national_number: 1010})
      {:ok, number} = ExPhoneNumber.parse("1010", "FR")
      assert is_valid_short_number?(number, "FR")
    end

    it "rejects a possible but invalid FR short number" do
      refute is_valid_short_number?(%PhoneNumber{country_code: 33, national_number: 123_456})
      {:ok, number} = ExPhoneNumber.parse("123456", "FR")
      refute is_valid_short_number?(number, "FR")
    end

    it "checks every region sharing the country code (GB and GG share 44)" do
      assert is_valid_short_number?(%PhoneNumber{country_code: 44, national_number: 18_001})
    end

    it "rejects a region that does not match the country code" do
      {:ok, number} = ExPhoneNumber.parse("1010", "FR")
      refute is_valid_short_number?(number, "US")
    end

    it "accepts the US short code from issue #69" do
      {:ok, number} = ExPhoneNumber.parse("88811", "US")
      assert is_valid_short_number?(number)
    end
  end
end

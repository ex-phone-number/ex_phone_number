defmodule ExPhoneNumber.UtilitiesTest do
  alias ExPhoneNumber.Model.PhoneNumber
  alias ExPhoneNumber.{PhoneNumberFixture, Utilities}

  use ExUnit.Case, async: true

  describe ".truncate_too_long_number/1" do
    test "when a valid number is passed in" do 
      valid = %PhoneNumber{
        country_code: 39,
        national_number: 2234567890,
        italian_leading_zero: true
      }

      {result, phone_number} = Utilities.truncate_too_long_number(valid)

      assert result == :ok
      assert phone_number == valid
    end

    test "GB number 080 1234 5678, but entered with 4 extra digits at the end." do
      invalid = %PhoneNumber{country_code: 44, national_number: 80_123_456_780_123}
      {result, phone_number} = Utilities.truncate_too_long_number(invalid)

      assert result == :ok
      assert phone_number == %PhoneNumber{country_code: 44, national_number: 8012345678}
    end

    test "IT number 022 3456 7890, but entered with 3 extra digits at the end." do 
      invalid = %PhoneNumber{
        country_code: 39,
        national_number: 2234567890123,
        italian_leading_zero: true
      }
      {result, phone_number} = Utilities.truncate_too_long_number(invalid)

      assert result == :ok
      assert phone_number == %PhoneNumber{
        country_code: 39,
        national_number: 2234567890,
        italian_leading_zero: true
      }
    end

    test "US number 650-253-0000, but entered with one additional digit at the end." do 
      invalid = %PhoneNumber{country_code: 1, national_number: 65025300001}
      {result, phone_number} = Utilities.truncate_too_long_number(invalid)

      assert result == :ok
      assert phone_number == %PhoneNumber{country_code: 1, national_number: 6502530000}
    end

    test "US Toll free number, but entered with one additional digit at the end." do 
      invalid = PhoneNumberFixture.international_toll_free_too_long()
      {result, phone_number} = Utilities.truncate_too_long_number(invalid)

      assert result == :ok
      assert phone_number == PhoneNumberFixture.international_toll_free()
    end

    test "A number with an invalid prefix is passed in (US numbers cannot have prefix 240)" do 
      invalid = PhoneNumberFixture.us_invalid_prefix()
      {result, phone_number} = Utilities.truncate_too_long_number(invalid)

      assert result == :error
      assert phone_number == invalid
    end

    test "A number that is too short" do 
      invalid = %PhoneNumber{country_code: 1, national_number: 1234}
      {result, phone_number} = Utilities.truncate_too_long_number(invalid)

      assert result == :error
      assert phone_number == invalid
    end
  end
end
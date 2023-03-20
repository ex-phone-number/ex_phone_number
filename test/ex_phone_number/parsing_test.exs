defmodule ExPhoneNumber.ParsingTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Parsing
  import ExPhoneNumber.Parsing
  alias ExPhoneNumber.Constants.ErrorMessages
  alias PhoneNumberFixture

  describe ".is_possible_number?/2" do
    context "US region" do
      it "should return true #1" do
        assert is_possible_number?("+1 650 253 0000", RegionCodeFixture.us())
      end

      it "should return true #2" do
        assert is_possible_number?("+1 650 GOO OGLE", RegionCodeFixture.us())
      end

      it "should return true #3" do
        assert is_possible_number?("(650) 253-0000", RegionCodeFixture.us())
      end

      it "should return true #4" do
        assert is_possible_number?("253-0000", RegionCodeFixture.us())
      end

      it "should return true #5" do
        assert is_possible_number?("+1 111 253 0000", RegionCodeFixture.us())
      end

      it "should return false #1" do
        refute is_possible_number?("+1 650 253 00000", RegionCodeFixture.us())
      end

      it "should return false #2" do
        refute is_possible_number?("(650) 253-00000", RegionCodeFixture.us())
      end

      it "should return false #3" do
        refute is_possible_number?("I want a Pizza", RegionCodeFixture.us())
      end

      it "should return false #4" do
        refute is_possible_number?("253-000", RegionCodeFixture.us())
      end
    end

    context "GB region" do
      it "should return true #1" do
        assert is_possible_number?("+1 650 253 0000", RegionCodeFixture.gb())
      end

      it "should return true #2" do
        assert is_possible_number?("+44 20 7031 3000", RegionCodeFixture.gb())
      end

      it "should return true #3" do
        assert is_possible_number?("(020) 7031 3000", RegionCodeFixture.gb())
      end

      it "should return true #4" do
        assert is_possible_number?("7031 3000", RegionCodeFixture.gb())
      end

      it "should return false #1" do
        refute is_possible_number?("1 3000", RegionCodeFixture.gb())
      end

      it "should return false #2" do
        refute is_possible_number?("+44 300", RegionCodeFixture.gb())
      end
    end

    context "NZ region" do
      it "should return true #1" do
        assert is_possible_number?("3331 6005", RegionCodeFixture.nz())
      end
    end

    context "UN001 region" do
      it "should return true #1" do
        assert is_possible_number?("+800 1234 5678", RegionCodeFixture.un001())
      end

      it "should return false #1" do
        refute is_possible_number?("+800 1234 5678 9", RegionCodeFixture.un001())
      end
    end
  end

  describe ".parse/2" do
    context "NZ number" do
      it "should return correct value #1" do
        {result, phone_number} = parse("033316005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("33316005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("03-331 6005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("03 331 6005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("tel:03-331-6005;phone-context=+64", RegionCodeFixture.nz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("tel:331-6005;phone-context=+64-3", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #7" do
        {result, phone_number} = parse("tel:331-6005;phone-context=+64-3", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #8" do
        {result, phone_number} = parse("My number is tel:03-331-6005;phone-context=+64", RegionCodeFixture.nz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #9" do
        {result, phone_number} = parse("tel:03-331-6005;phone-context=+64;a=%A1", RegionCodeFixture.nz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #10" do
        {result, phone_number} = parse("tel:03-331-6005;isub=12345;phone-context=+64", RegionCodeFixture.nz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #11" do
        {result, phone_number} = parse("tel:+64-3-331-6005;isub=12345", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #12" do
        {result, phone_number} = parse("03-331-6005;phone-context=+64", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #13" do
        {result, phone_number} = parse("0064 3 331 6005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #14" do
        {result, phone_number} = parse("01164 3 331 6005", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #15" do
        {result, phone_number} = parse("+64 3 331 6005", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #16" do
        {result, phone_number} = parse("+01164 3 331 6005", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #17" do
        {result, phone_number} = parse("+0064 3 331 6005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should return correct value #18" do
        {result, phone_number} = parse("+ 00 64 3 331 6005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end
    end

    context "NZ number3" do
      it "should return correct value" do
        {result, phone_number} = parse("64(0)64123456", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number3() == phone_number
      end
    end

    context "NZ short number" do
      it "should return correct value" do
        {result, phone_number} = parse("12", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_short_number() == phone_number
      end
    end

    context "DE number" do
      it "should return correct value" do
        {result, phone_number} = parse("301/23456", RegionCodeFixture.de())
        assert :ok == result
        assert PhoneNumberFixture.de_number() == phone_number
      end
    end

    context "JP star number" do
      it "should return correct value" do
        {result, phone_number} = parse("+81 *2345", RegionCodeFixture.jp())
        assert :ok == result
        assert PhoneNumberFixture.jp_star_number() == phone_number
      end
    end

    context "US number2" do
      it "should return correct value" do
        {result, phone_number} = parse("123-456-7890", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number2() == phone_number
      end
    end

    context "US local number" do
      it "should return correct value #1" do
        {result, phone_number} = parse("tel:253-0000;phone-context=www.google.com", RegionCodeFixture.us())

        assert :ok == result
        assert PhoneNumberFixture.us_local_number() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("tel:253-0000;isub=12345;phone-context=www.google.com", RegionCodeFixture.us())

        assert :ok == result
        assert PhoneNumberFixture.us_local_number() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("tel:2530000;isub=12345;phone-context=1-650", RegionCodeFixture.us())

        assert :ok == result
        assert PhoneNumberFixture.us_local_number() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("tel:2530000;isub=12345;phone-context=1234.com", RegionCodeFixture.us())

        assert :ok == result
        assert PhoneNumberFixture.us_local_number() == phone_number
      end
    end

    context "AR numbers" do
      it "should return correct value #1" do
        {result, phone_number} = parse("+54 9 343 555 1212", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_mobile2() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("0343 15 555 1212", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_mobile2() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("+54 9 3715 65 4320", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_mobile3() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("03715 15 65 4320", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_mobile3() == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("911 876 54321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_mobile() == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("+54 11 8765 4321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number() == phone_number
      end

      it "should return correct value #7" do
        {result, phone_number} = parse("011 8765 4321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number() == phone_number
      end

      it "should return correct value #8" do
        {result, phone_number} = parse("+54 3715 65 4321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number3() == phone_number
      end

      it "should return correct value #9" do
        {result, phone_number} = parse("03715 65 4321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number3() == phone_number
      end

      it "should return correct value #10" do
        {result, phone_number} = parse("023 1234 0000", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number4() == phone_number
      end

      it "should return correct value #11" do
        {result, phone_number} = parse("+54 23 1234 0000", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number4() == phone_number
      end

      it "should return correct value #12" do
        {result, phone_number} = parse("01187654321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number() == phone_number
      end

      it "should return correct value #13" do
        {result, phone_number} = parse("(0) 1187654321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number() == phone_number
      end

      it "should return correct value #14" do
        {result, phone_number} = parse("0 1187654321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number() == phone_number
      end

      it "should return correct value #15" do
        {result, phone_number} = parse("(0xx) 1187654321", RegionCodeFixture.ar())
        assert :ok == result
        assert PhoneNumberFixture.ar_number() == phone_number
      end

      it "should return correct value #16" do
        {result, phone_number} = parse("011xx5481429712", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.ar_number5() == phone_number
      end
    end

    context "MX numbers" do
      it "should return correct value #1" do
        {result, phone_number} = parse("+52 (449)978-0001", RegionCodeFixture.mx())
        assert :ok == result
        assert PhoneNumberFixture.mx_number3() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("01 (449)978-0001", RegionCodeFixture.mx())
        assert :ok == result
        assert PhoneNumberFixture.mx_number3() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("(449)978-0001", RegionCodeFixture.mx())
        assert :ok == result
        assert PhoneNumberFixture.mx_number3() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("+52 1 33 1234-5678", RegionCodeFixture.mx())
        assert :ok == result
        assert PhoneNumberFixture.mx_number4() == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("044 (33) 1234-5678", RegionCodeFixture.mx())
        assert :ok == result
        assert PhoneNumberFixture.mx_number4() == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("045 33 1234-5678", RegionCodeFixture.mx())
        assert :ok == result
        assert PhoneNumberFixture.mx_number4() == phone_number
      end
    end

    context "Number with alpha chars" do
      it "should return correct value #1" do
        {result, phone_number} = parse("0800 DDA 005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_toll_free() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("0900 DDA 6005", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_premium() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("0900 332 6005a", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_premium() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("0900 332 600a5", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_premium() == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("0900 332 600A5", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_premium() == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("0900 a332 600A5", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_premium() == phone_number
      end
    end

    context "Number with international prefix" do
      it "should return correct value #1" do
        {result, phone_number} = parse("+1 (650) 253-0000", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("011 800 1234 5678", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.international_toll_free() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("1-650-253-0000", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} = parse("0011-650-253-0000", RegionCodeFixture.sg())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #5" do
        {result, phone_number} = parse("0081-650-253-0000", RegionCodeFixture.sg())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #6" do
        {result, phone_number} = parse("0191-650-253-0000", RegionCodeFixture.sg())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #7" do
        {result, phone_number} = parse("0~01-650-253-0000", RegionCodeFixture.pl())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #8" do
        {result, phone_number} = parse("++1 (650) 253-0000", RegionCodeFixture.pl())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end
    end

    context "Non Ascii" do
      it "should return correct value #1" do
        {result, phone_number} = parse("\uFF0B1 (650) 253-0000", RegionCodeFixture.sg())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("1 (650) 253\u00AD-0000", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} =
          parse(
            "\uFF0B\uFF11\u3000\uFF08\uFF16\uFF15\uFF10\uFF09\u3000\uFF12\uFF15\uFF13\uFF0D\uFF10\uFF10\uFF10\uFF10",
            RegionCodeFixture.sg()
          )

        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end

      it "should return correct value #4" do
        {result, phone_number} =
          parse(
            "\uFF0B\uFF11\u3000\uFF08\uFF16\uFF15\uFF10\uFF09\u3000\uFF12\uFF15\uFF13\u30FC\uFF10\uFF10\uFF10\uFF10",
            RegionCodeFixture.sg()
          )

        assert :ok == result
        assert PhoneNumberFixture.us_number() == phone_number
      end
    end

    context "With Leading Zero" do
      it "should return correct value #1" do
        {result, phone_number} = parse("+39 02-36618 300", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.it_number() == phone_number
      end

      it "should return correct value #2" do
        {result, phone_number} = parse("02-36618 300", RegionCodeFixture.it())
        assert :ok == result
        assert PhoneNumberFixture.it_number() == phone_number
      end

      it "should return correct value #3" do
        {result, phone_number} = parse("345 678 901", RegionCodeFixture.it())
        assert :ok == result
        assert PhoneNumberFixture.it_mobile() == phone_number
      end
    end

    context "Invalid numbers" do
      it "should match the error message #1" do
        {result, message} = parse("This is not a phone number", RegionCodeFixture.nz())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #2" do
        {result, message} = parse("1 Still not a number", RegionCodeFixture.nz())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #3" do
        {result, message} = parse("1 MICROSOFT", RegionCodeFixture.nz())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #4" do
        {result, message} = parse("12 MICROSOFT", RegionCodeFixture.nz())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #5" do
        {result, message} = parse("01495 72553301873 810104", RegionCodeFixture.gb())
        assert :error == result
        assert ErrorMessages.too_long() == message
      end

      it "should match the error message #6" do
        {result, message} = parse("+---", RegionCodeFixture.de())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #7" do
        {result, message} = parse("+***", RegionCodeFixture.de())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #8" do
        {result, message} = parse("+*******91", RegionCodeFixture.de())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #9" do
        {result, message} = parse("+49 0", RegionCodeFixture.de())
        assert :error == result
        assert ErrorMessages.too_short_nsn() == message
      end

      it "should match the error message #10" do
        {result, message} = parse("+210 3456 56789", RegionCodeFixture.nz())
        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end

      it "should match the error message #11" do
        {result, message} = parse("+ 00 210 3 331 6005", RegionCodeFixture.nz())
        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end

      it "should match the error message #12" do
        {result, message} = parse("123 456 7890", RegionCodeFixture.zz())
        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end

      it "should match the error message #13" do
        {result, message} = parse("123 456 7890", RegionCodeFixture.cs())
        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end

      it "should match the error message #14" do
        {result, message} = parse("123 456 7890", nil)
        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end

      it "should match the error message #15" do
        {result, message} = parse("0044------", RegionCodeFixture.gb())
        assert :error == result
        assert ErrorMessages.too_short_after_idd() == message
      end

      it "should match the error message #16" do
        {result, message} = parse("0044", RegionCodeFixture.gb())
        assert :error == result
        assert ErrorMessages.too_short_after_idd() == message
      end

      it "should match the error message #17" do
        {result, message} = parse("011", RegionCodeFixture.us())
        assert :error == result
        assert ErrorMessages.too_short_after_idd() == message
      end

      it "should match the error message #18" do
        {result, message} = parse("0119", RegionCodeFixture.us())
        assert :error == result
        assert ErrorMessages.too_short_after_idd() == message
      end

      it "should match the error message #19" do
        {result, message} = parse("", RegionCodeFixture.zz())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #20" do
        {result, message} = parse(nil, RegionCodeFixture.zz())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #21" do
        {result, message} = parse(nil, RegionCodeFixture.us())
        assert :error == result
        assert ErrorMessages.not_a_number() == message
      end

      it "should match the error message #22" do
        {result, message} = parse("tel:555-1234;phone-context=www.google.com", RegionCodeFixture.zz())

        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end

      it "should match the error message #23" do
        {result, message} = parse("tel:555-1234;phone-context=1-331", RegionCodeFixture.zz())
        assert :error == result
        assert ErrorMessages.invalid_country_code() == message
      end
    end

    context "With plus sign with no region" do
      it "should match the phone number #1" do
        {result, phone_number} = parse("+64 3 331 6005", RegionCodeFixture.zz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should match the phone number #2" do
        {result, phone_number} = parse("\uFF0B64 3 331 6005", RegionCodeFixture.zz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should match the phone number #3" do
        {result, phone_number} = parse("Tel: +64 3 331 6005", RegionCodeFixture.zz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should match the phone number #4" do
        {result, phone_number} = parse("+64 3 331 6005", nil)
        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should match the phone number #5" do
        {result, phone_number} = parse("+800 1234 5678", nil)
        assert :ok == result
        assert PhoneNumberFixture.international_toll_free() == phone_number
      end

      it "should match the phone number #6" do
        {result, phone_number} = parse("+979 123 456 789", nil)
        assert :ok == result
        assert PhoneNumberFixture.universal_premium_rate() == phone_number
      end

      it "should match the phone number #7" do
        {result, phone_number} = parse("tel:03-331-6005;phone-context=+64", RegionCodeFixture.zz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should match the phone number #8" do
        {result, phone_number} = parse("  tel:03-331-6005;phone-context=+64", RegionCodeFixture.zz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end

      it "should match the phone number #9" do
        {result, phone_number} = parse("tel:03-331-6005;isub=12345;phone-context=+64", RegionCodeFixture.zz())

        assert :ok == result
        assert PhoneNumberFixture.nz_number() == phone_number
      end
    end

    context "Too short if national prefix stripped" do
      it "should match the phone number #1" do
        {result, phone_number} = parse("8123", RegionCodeFixture.by())
        assert :ok == result
        assert PhoneNumberFixture.by_number() == phone_number
      end

      it "should match the phone number #2" do
        {result, phone_number} = parse("81234", RegionCodeFixture.by())
        assert :ok == result
        assert PhoneNumberFixture.by_number2() == phone_number
      end

      it "should match the phone number #3" do
        {result, phone_number} = parse("812345", RegionCodeFixture.by())
        assert :ok == result
        assert PhoneNumberFixture.by_number3() == phone_number
      end

      it "should match the phone number #4" do
        {result, phone_number} = parse("8123456", RegionCodeFixture.by())
        assert :ok == result
        assert PhoneNumberFixture.by_number4() == phone_number
      end
    end

    context "Number with extension" do
      it "should match the phone number #1" do
        {result, phone_number} = parse("03 331 6005 ext 3456", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number4() == phone_number
      end

      it "should match the phone number #2" do
        {result, phone_number} = parse("03-3316005x3456", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number4() == phone_number
      end

      it "should match the phone number #3" do
        {result, phone_number} = parse("03-3316005 int.3456", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number4() == phone_number
      end

      it "should match the phone number #4" do
        {result, phone_number} = parse("03 3316005 #3456", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.nz_number4() == phone_number
      end

      it "should match the phone number #5" do
        {result, phone_number} = parse("1800 six-flags", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.alpha_numeric_number() == phone_number
      end

      it "should match the phone number #6" do
        {result, phone_number} = parse("1800 SIX FLAGS", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.alpha_numeric_number() == phone_number
      end

      it "should match the phone number #7" do
        {result, phone_number} = parse("0~0 1800 7493 5247", RegionCodeFixture.pl())
        assert :ok == result
        assert PhoneNumberFixture.alpha_numeric_number() == phone_number
      end

      it "should match the phone number #8" do
        {result, phone_number} = parse("(1800) 7493.5247", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.alpha_numeric_number() == phone_number
      end

      it "should match the phone number #9" do
        {result, phone_number} = parse("0~0 1800 7493 5247 ~1234", RegionCodeFixture.pl())
        assert :ok == result
        assert PhoneNumberFixture.alpha_numeric_number2() == phone_number
      end

      it "should match the phone number #10" do
        {result, phone_number} = parse("+44 2034567890x456", RegionCodeFixture.nz())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #11" do
        {result, phone_number} = parse("+44 2034567890x456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #12" do
        {result, phone_number} = parse("+44 2034567890 x456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #13" do
        {result, phone_number} = parse("+44 2034567890 X456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #14" do
        {result, phone_number} = parse("+44 2034567890 X 456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #15" do
        {result, phone_number} = parse("+44 2034567890 X  456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #16" do
        {result, phone_number} = parse("44 2034567890 x 456  ", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #17" do
        {result, phone_number} = parse("+44 2034567890  X 456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #18" do
        {result, phone_number} = parse("+44-2034567890;ext=456", RegionCodeFixture.gb())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #19" do
        {result, phone_number} = parse("tel:2034567890;ext=456;phone-context=+44", RegionCodeFixture.zz())

        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #20" do
        {result, phone_number} = parse("+442034567890\uFF45\uFF58\uFF54\uFF4E456", RegionCodeFixture.zz())

        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #21" do
        {result, phone_number} = parse("+442034567890\uFF58\uFF54\uFF4E456", RegionCodeFixture.zz())

        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #22" do
        {result, phone_number} = parse("+442034567890\uFF58\uFF54456", RegionCodeFixture.zz())
        assert :ok == result
        assert PhoneNumberFixture.gb_number2() == phone_number
      end

      it "should match the phone number #23" do
        {result, phone_number} = parse("(212)123-1234 x508/x1234", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number_with_extension() == phone_number
      end

      it "should match the phone number #24" do
        {result, phone_number} = parse("(212)123-1234 x508/ x1234", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number_with_extension() == phone_number
      end

      it "should match the phone number #25" do
        {result, phone_number} = parse("(212)123-1234 x508\\x1234", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number_with_extension() == phone_number
      end

      it "should match the phone number #26" do
        {result, phone_number} = parse("+1 (645) 123 1234-910#", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number_with_extension2() == phone_number
      end

      it "should match the phone number #27" do
        {result, phone_number} = parse("+1 (645) 123 1234 ext. 910#", RegionCodeFixture.us())
        assert :ok == result
        assert PhoneNumberFixture.us_number_with_extension2() == phone_number
      end
    end

    context "Italian leading zero" do
      it "should match the phone number #1" do
        {result, phone_number} = parse("011", RegionCodeFixture.au())
        assert :ok == result
        assert PhoneNumberFixture.au_leading_zero() == phone_number
      end

      it "should match the phone number #2" do
        {result, phone_number} = parse("001", RegionCodeFixture.au())
        assert :ok == result
        assert PhoneNumberFixture.au_leading_zero2() == phone_number
      end

      it "should match the phone number #3" do
        {result, phone_number} = parse("000", RegionCodeFixture.au())
        assert :ok == result
        assert PhoneNumberFixture.au_leading_zero3() == phone_number
      end

      it "should match the phone number #4" do
        {result, phone_number} = parse("0000", RegionCodeFixture.au())
        assert :ok == result
        assert PhoneNumberFixture.au_leading_zero4() == phone_number
      end
    end
  end
end

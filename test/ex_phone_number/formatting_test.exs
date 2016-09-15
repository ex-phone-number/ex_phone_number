defmodule ExPhoneNumber.FormattingTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Formatting
  import ExPhoneNumber.Formatting
  alias ExPhoneNumber.Constants.PhoneNumberFormats
  alias PhoneNumberFixture

  describe ".format/2" do
    context "US number" do
      it "should return correct value #1" do
        assert "650 253 0000" == format(PhoneNumberFixture.us_number, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+1 650 253 0000" == format(PhoneNumberFixture.us_number, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "800 253 0000" == format(PhoneNumberFixture.us_tollfree, PhoneNumberFormats.national)
      end

      it "should return correct value #4" do
        assert "+1 800 253 0000" == format(PhoneNumberFixture.us_tollfree, PhoneNumberFormats.international)
      end

      it "should return correct value #5" do
        assert "900 253 0000" == format(PhoneNumberFixture.us_premium, PhoneNumberFormats.national)
      end

      it "should return correct value #6" do
        assert "+1 900 253 0000" == format(PhoneNumberFixture.us_premium, PhoneNumberFormats.international)
      end

      it "should return correct value #7" do
        assert "tel:+1-900-253-0000" == format(PhoneNumberFixture.us_premium, PhoneNumberFormats.rfc3966)
      end

      it "should return correct value #8" do
        assert "000-000-0000" == format(PhoneNumberFixture.us_spoof_with_raw_input, PhoneNumberFormats.national)
      end

      it "should return correct value #9" do
        assert "0" == format(PhoneNumberFixture.us_spoof, PhoneNumberFormats.national)
      end
    end

    context "BS number" do
      it "should return correct value #1" do
        assert "242 365 1234" == format(PhoneNumberFixture.bs_number, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+1 242 365 1234" == format(PhoneNumberFixture.bs_number, PhoneNumberFormats.international)
      end
    end

    context "GB number" do
      it "should return correct value #1" do
        assert "(020) 7031 3000" == format(PhoneNumberFixture.gb_number, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+44 20 7031 3000" == format(PhoneNumberFixture.gb_number, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "(07912) 345 678" == format(PhoneNumberFixture.gb_mobile, PhoneNumberFormats.national)
      end

      it "should return correct value #4" do
        assert "+44 7912 345 678" == format(PhoneNumberFixture.gb_mobile, PhoneNumberFormats.international)
      end
    end

    context "DE number" do
      it "should return correct value #1" do
        assert "030/1234" == format(PhoneNumberFixture.de_number2, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+49 30/1234" == format(PhoneNumberFixture.de_number2, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "tel:+49-30-1234" == format(PhoneNumberFixture.de_number2, PhoneNumberFormats.rfc3966)
      end

      it "should return correct value #4" do
        assert "0291 123" == format(PhoneNumberFixture.de_number3, PhoneNumberFormats.national)
      end

      it "should return correct value #5" do
        assert "+49 291 123" == format(PhoneNumberFixture.de_number3, PhoneNumberFormats.international)
      end

      it "should return correct value #6" do
        assert "0291 12345678" == format(PhoneNumberFixture.de_number4, PhoneNumberFormats.national)
      end

      it "should return correct value #7" do
        assert "+49 291 12345678" == format(PhoneNumberFixture.de_number4, PhoneNumberFormats.international)
      end

      it "should return correct value #8" do
        assert "09123 12345" == format(PhoneNumberFixture.de_number5, PhoneNumberFormats.national)
      end

      it "should return correct value #9" do
        assert "+49 9123 12345" == format(PhoneNumberFixture.de_number5, PhoneNumberFormats.international)
      end

      it "should return correct value #10" do
        assert "08021 2345" == format(PhoneNumberFixture.de_number6, PhoneNumberFormats.national)
      end

      it "should return correct value #11" do
        assert "+49 8021 2345" == format(PhoneNumberFixture.de_number6, PhoneNumberFormats.international)
      end

      it "should return correct value #12" do
        assert "1234" == format(PhoneNumberFixture.de_short_number, PhoneNumberFormats.national)
      end

      it "should return correct value #13" do
        assert "+49 1234" == format(PhoneNumberFixture.de_short_number, PhoneNumberFormats.international)
      end

      it "should return correct value #14" do
        assert "04134 1234" == format(PhoneNumberFixture.de_number7, PhoneNumberFormats.national)
      end
    end

    context "IT numbers" do
      it "should return correct value #1" do
        assert "02 3661 8300" == format(PhoneNumberFixture.it_number, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+39 02 3661 8300" == format(PhoneNumberFixture.it_number, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "+390236618300" == format(PhoneNumberFixture.it_number, PhoneNumberFormats.e164)
      end

      it "should return correct value #4" do
        assert "345 678 901" == format(PhoneNumberFixture.it_mobile, PhoneNumberFormats.national)
      end

      it "should return correct value #5" do
        assert "+39 345 678 901" == format(PhoneNumberFixture.it_mobile, PhoneNumberFormats.international)
      end

      it "should return correct value #6" do
        assert "+39345678901" == format(PhoneNumberFixture.it_mobile, PhoneNumberFormats.e164)
      end
    end

    context "AU numbers" do
      it "should return correct value #1" do
        assert "02 3661 8300" == format(PhoneNumberFixture.au_number, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+61 2 3661 8300" == format(PhoneNumberFixture.au_number, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "+61236618300" == format(PhoneNumberFixture.au_number, PhoneNumberFormats.e164)
      end

      it "should return correct value #4" do
        assert "1800 123 456" == format(PhoneNumberFixture.au_number2, PhoneNumberFormats.national)
      end

      it "should return correct value #5" do
        assert "+61 1800 123 456" == format(PhoneNumberFixture.au_number2, PhoneNumberFormats.international)
      end

      it "should return correct value #6" do
        assert "+611800123456" == format(PhoneNumberFixture.au_number2, PhoneNumberFormats.e164)
      end
    end

    context "AR numbers" do
      it "should return correct value #1" do
        assert "011 8765-4321" == format(PhoneNumberFixture.ar_number, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+54 11 8765-4321" == format(PhoneNumberFixture.ar_number, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "+541187654321" == format(PhoneNumberFixture.ar_number, PhoneNumberFormats.e164)
      end

      it "should return correct value #4" do
        assert "011 15 8765-4321" == format(PhoneNumberFixture.ar_mobile, PhoneNumberFormats.national)
      end

      it "should return correct value #5" do
        assert "+54 9 11 8765 4321" == format(PhoneNumberFixture.ar_mobile, PhoneNumberFormats.international)
      end

      it "should return correct value #6" do
        assert "+5491187654321" == format(PhoneNumberFixture.ar_mobile, PhoneNumberFormats.e164)
      end
    end

    context "MX numbers" do
      it "should return correct value #1" do
        assert "045 234 567 8900" == format(PhoneNumberFixture.mx_mobile1, PhoneNumberFormats.national)
      end

      it "should return correct value #2" do
        assert "+52 1 234 567 8900" == format(PhoneNumberFixture.mx_mobile1, PhoneNumberFormats.international)
      end

      it "should return correct value #3" do
        assert "+5212345678900" == format(PhoneNumberFixture.mx_mobile1, PhoneNumberFormats.e164)
      end

      it "should return correct value #4" do
        assert "045 55 1234 5678" == format(PhoneNumberFixture.mx_mobile2, PhoneNumberFormats.national)
      end

      it "should return correct value #5" do
        assert "+52 1 55 1234 5678" == format(PhoneNumberFixture.mx_mobile2, PhoneNumberFormats.international)
      end

      it "should return correct value #6" do
        assert "+5215512345678" == format(PhoneNumberFixture.mx_mobile2, PhoneNumberFormats.e164)
      end

      it "should return correct value #7" do
        assert "01 33 1234 5678" == format(PhoneNumberFixture.mx_number1, PhoneNumberFormats.national)
      end

      it "should return correct value #8" do
        assert "+52 33 1234 5678" == format(PhoneNumberFixture.mx_number1, PhoneNumberFormats.international)
      end

      it "should return correct value #9" do
        assert "+523312345678" == format(PhoneNumberFixture.mx_number1, PhoneNumberFormats.e164)
      end

      it "should return correct value #10" do
        assert "01 821 123 4567" == format(PhoneNumberFixture.mx_number2, PhoneNumberFormats.national)
      end

      it "should return correct value #11" do
        assert "+52 821 123 4567" == format(PhoneNumberFixture.mx_number2, PhoneNumberFormats.international)
      end

      it "should return correct value #12" do
        assert "+528211234567" == format(PhoneNumberFixture.mx_number2, PhoneNumberFormats.e164)
      end
    end

    context "E164 numbers" do
      it "should return correct value #0" do
        assert "+16502530000" == format(PhoneNumberFixture.us_number, PhoneNumberFormats.e164)
      end

      it "should return correct value #1" do
        assert "+4930123456" == format(PhoneNumberFixture.de_number, PhoneNumberFormats.e164)
      end

      it "should return correct value #2" do
        assert "+80012345678" == format(PhoneNumberFixture.international_toll_free, PhoneNumberFormats.e164)
      end
    end

    context "Numbers with extensions" do
      it "should return correct value #0" do
        assert "03-331 6005 ext. 1234" == format(%{PhoneNumberFixture.nz_number | extension: "1234"}, PhoneNumberFormats.national)
      end

      it "should return correct value #1" do
        assert "tel:+64-3-331-6005;ext=1234" == format(%{PhoneNumberFixture.nz_number | extension: "1234"}, PhoneNumberFormats.rfc3966)
      end

      it "should return correct value #2" do
        assert "650 253 0000 extn. 4567" == format(%{PhoneNumberFixture.us_number | extension: "4567"}, PhoneNumberFormats.national)
      end
    end
  end
end

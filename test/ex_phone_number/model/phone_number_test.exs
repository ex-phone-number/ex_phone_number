defmodule ExPhoneNumber.Model.PhoneNumberTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Model.PhoneNumber
  import ExPhoneNumber.Model.PhoneNumber
  import PhoneNumberFixture

  describe ".get_national_significant_number/1" do
    context "US number" do
      it "returns true" do
        assert "6502530000" == get_national_significant_number(us_number())
      end
    end

    context "IT mobile" do
      it "returns true" do
        assert "345678901" == get_national_significant_number(it_mobile())
      end
    end

    context "IT number" do
      it "returns true" do
        assert "0236618300" == get_national_significant_number(it_number())
      end
    end

    context "International Toll Free" do
      it "returns true" do
        assert "12345678" == get_national_significant_number(international_toll_free())
      end
    end

  end
end

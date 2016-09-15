defmodule ExPhoneNumber.NormalizationTest do
  use ExSpec, async: true

  doctest ExPhoneNumber.Normalization
  import ExPhoneNumber.Normalization

  describe ".convert_alpha_chars_in_number" do
    context "1-800-ABC" do
      it "returns correct value" do
        subject = "1800-ABC-DEF"
        assert "1800-222-333" == convert_alpha_chars_in_number(subject)
      end
    end
  end

  describe ".normalize" do
    context "number with puntuaction" do
      it "returns correct value" do
        subject = "034-56&+#2\u00AD34"
        assert "03456234" == normalize(subject)
      end
    end

    context "number with alpha chars" do
      it "returns correct value" do
        subject = "034-I-am-HUNGRY"
        assert "034426486479" == normalize(subject)
      end
    end

    context "number with unicode digits" do
      it "returns correct value" do
        subject = "\uFF125\u0665"
        assert "255" == normalize(subject)
      end
    end

    context "number with eastern-arabic digits" do
      it "returns correct value" do
        subject = "\u06F52\u06F0"
        assert "520" == normalize(subject)
      end
    end
  end

  describe "normalize_digits_only" do
    context "number with alpha chars and puntuaction" do
      it "returns correct value" do
        subject = "034-56&+a#234"
        assert "03456234" == normalize_digits_only(subject)
      end
    end
  end
end

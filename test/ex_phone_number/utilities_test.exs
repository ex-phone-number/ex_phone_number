defmodule ExPhoneNumber.UtilitiesTest do
  use ExSpec, async: true

  import ExPhoneNumber.Utilities

  describe ".compile_regex" do
    context "a valid source" do
      it "compiles it once and returns the same regex afterwards" do
        source = "^cached-#{System.unique_integer([:positive])}$"

        assert {:ok, regex} = compile_regex(source, "u")
        assert {:ok, ^regex} = compile_regex(source, "u")
        assert Regex.match?(regex, String.slice(source, 1..-2//1))
      end

      it "keeps sources compiled with different options apart" do
        source = "^case-#{System.unique_integer([:positive])}$"

        assert {:ok, sensitive} = compile_regex(source)
        assert {:ok, insensitive} = compile_regex(source, "i")
        refute Regex.match?(sensitive, String.upcase(String.slice(source, 1..-2//1)))
        assert Regex.match?(insensitive, String.upcase(String.slice(source, 1..-2//1)))
      end
    end

    context "an invalid source" do
      it "returns the compile error, and the bang version raises it" do
        assert {:error, _reason} = compile_regex("(")
        assert_raise Regex.CompileError, fn -> compile_regex!("(") end
      end
    end
  end
end

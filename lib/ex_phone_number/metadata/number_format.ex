defmodule ExPhoneNumber.Metadata.NumberFormat do
  alias ExPhoneNumber.Metadata.Normalize
  @moduledoc false

  # string
  defstruct pattern: nil,
            # string
            format: nil,
            # string
            leading_digits_pattern: nil,
            # string
            national_prefix_formatting_rule: nil,
            # boolean
            national_prefix_optional_when_formatting: nil,
            # string
            domestic_carrier_code_formatting_rule: nil,
            # string
            intl_format: nil

  import SweetXml
  alias ExPhoneNumber.Metadata.NumberFormat

  def from_xpath_node(nil), do: nil

  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node
      |> xmap(
        pattern: ~x"./@pattern"s |> transform_by(&Normalize.pattern/1),
        format: ~x"./format/text()"s |> transform_by(&Normalize.rule/1),
        leading_digits_pattern: [
          ~x"./leadingDigits"el,
          pattern: ~x"./text()"s |> transform_by(&Normalize.pattern/1)
        ],
        national_prefix_formatting_rule: ~x"./@nationalPrefixFormattingRule"so |> transform_by(&Normalize.string/1),
        national_prefix_optional_when_formatting: ~x"./@nationalPrefixOptionalWhenFormatting"so |> transform_by(&Normalize.boolean/1),
        domestic_carrier_code_formatting_rule: ~x"./@carrierCodeFormattingRule"so |> transform_by(&Normalize.string/1),
        intl_format: ~x"./intlFormat/text()"o |> transform_by(&Normalize.rule/1)
      )

    struct(%NumberFormat{}, kwlist)
  end
end

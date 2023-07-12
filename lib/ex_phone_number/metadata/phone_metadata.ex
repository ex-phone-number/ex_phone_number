defmodule ExPhoneNumber.Metadata.PhoneMetadata do
  @moduledoc false

  # string
  defstruct id: nil,
            # number
            country_code: nil,
            # string
            leading_digits: nil,
            # string
            international_prefix: nil,
            # string
            preferred_international_prefix: nil,
            # string
            national_prefix: nil,
            # string
            national_prefix_for_parsing: nil,
            # string
            national_prefix_transform_rule: nil,
            # string
            national_prefix_formatting_rule: nil,
            # string
            national_prefix_optional_when_formatting: nil,
            # string
            preferred_extn_prefix: nil,
            # boolean
            main_country_for_code: nil,
            # boolean
            mobile_number_portable_region: nil,
            # string
            carrier_code_formatting_rule: nil,
            # %PhoneNumberDescription{}
            general: nil,
            # %PhoneNumberDescription{}
            fixed_line: nil,
            # %PhoneNumberDescription{}
            mobile: nil,
            # %PhoneNumberDescription{}
            toll_free: nil,
            # %PhoneNumberDescription{}
            premium_rate: nil,
            # %PhoneNumberDescription{}
            shared_cost: nil,
            # %PhoneNumberDescription{}
            personal_number: nil,
            # %PhoneNumberDescription{}
            voip: nil,
            # %PhoneNumberDescription{}
            pager: nil,
            # %PhoneNumberDescription{}
            uan: nil,
            # %PhoneNumberDescription{}
            voicemail: nil,
            # %PhoneNumberDescription{}
            no_international_dialing: nil,
            # boolean
            same_mobile_and_fixed_line_pattern: nil,
            # [%NumberFormat{}]
            available_formats: [],
            # [%NumberFormat{}]
            number_format: [],
            # [%NumberFormat{}]
            intl_number_format: []

  import SweetXml
  import ExPhoneNumber.Utilities
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.NumberFormat
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  require Logger
  Logger.configure(level: Application.compile_env(:ex_phone_number, :log_level, :warning))

  def from_xpath_node(xpath_node) do
    kwlist =
      xpath_node
      |> xmap(
        id: ~x"./@id"s,
        country_code: ~x"./@countryCode"i,
        leading_digits: ~x"./@leadingDigits"o |> transform_by(&normalize_pattern/1),
        international_prefix: ~x"./@internationalPrefix"s,
        preferred_international_prefix: ~x"./@preferredInternationalPrefix"o |> transform_by(&normalize_string/1),
        national_prefix: ~x"./@nationalPrefix"s,
        national_prefix_for_parsing: ~x"./@nationalPrefixForParsing"o |> transform_by(&normalize_string/1),
        national_prefix_transform_rule: ~x"./@nationalPrefixTransformRule"o |> transform_by(&normalize_rule/1),
        national_prefix_formatting_rule: ~x"./@nationalPrefixFormattingRule"s,
        preferred_extn_prefix: ~x"./@preferredExtnPrefix"o |> transform_by(&normalize_string/1),
        main_country_for_code: ~x"./@mainCountryForCode"o |> transform_by(&normalize_boolean/1),
        mobile_number_portable_region: ~x"./@mobileNumberPortableRegion"o |> transform_by(&normalize_boolean/1),
        carrier_code_formatting_rule: ~x"./@carrierCodeFormattingRule"s,
        general: ~x"./generalDesc"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        fixed_line: ~x"./fixedLine"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        mobile: ~x"./mobile"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        toll_free: ~x"./tollFree"o |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        premium_rate: ~x"./premiumRate"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        shared_cost: ~x"./sharedCost"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        personal_number: ~x"./personalNumber"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        voip: ~x"./voip"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        pager: ~x"./pager"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        uan: ~x"./uan"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        voicemail: ~x"./voicemail"e |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        no_international_dialing:
          ~x"./noInternationalDialling"e
          |> transform_by(&PhoneNumberDescription.from_xpath_node/1),
        available_formats: [
          ~x"./availableFormats/numberFormat"el,
          number_format: ~x"."e |> transform_by(&NumberFormat.from_xpath_node/1)
        ]
      )

    kwlist =
      if(is_map(kwlist) && is_map(kwlist.general)) do
        put_in(kwlist.general.possible_lengths, general_possible_lengths(kwlist))
      else
        kwlist
      end

    struct(%PhoneMetadata{}, kwlist)
  end

  defp general_possible_lengths(kwlist) do
    [
      :fixed_line,
      :mobile,
      :toll_free,
      :premium_rate,
      :shared_cost,
      :personal_number,
      :voip,
      :pager,
      :uan,
      :voicemail,
      :no_international_dialing
    ]
    |> Enum.flat_map(fn type ->
      kwlist
      |> Map.get(type)
      |> get_possible_length()
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp get_possible_length(nil), do: []

  defp get_possible_length(phone_number_description = %PhoneNumberDescription{}),
    do: phone_number_description.possible_lengths || []

  defp normalize_rule(nil), do: nil

  defp normalize_rule(char_list) when is_list(char_list),
    do: char_list |> List.to_string() |> normalize_rule()

  defp normalize_rule(string) when is_binary(string) do
    string
    |> String.replace(~r/\$(\d)/, "\\\\g{\\g{1}}")
  end

  defp normalize_pattern(nil), do: nil

  defp normalize_pattern(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
    |> String.split(["\n", " "], trim: true)
    |> List.to_string()
    |> Regex.compile!()
  end

  defp normalize_string(nil), do: nil

  defp normalize_string(char_list) when is_list(char_list) do
    char_list
    |> List.to_string()
  end

  defp normalize_boolean(nil), do: false

  defp normalize_boolean(true_char_list)
       when is_list(true_char_list) and length(true_char_list) == 4,
       do: true

  defp get_map_key(%PhoneMetadata{} = phone_metadata) do
    if Integer.parse(phone_metadata.id) != :error do
      Integer.to_string(phone_metadata.country_code)
    else
      phone_metadata.id
    end
  end

  def is_main_country_for_code?(nil), do: nil

  def is_main_country_for_code?(%PhoneMetadata{} = phone_metadata) do
    not is_nil(phone_metadata.main_country_for_code) and phone_metadata.main_country_for_code
  end

  @same_mobile_and_fixed_line_pattern_default false
  def get_same_mobile_and_fixed_line_pattern_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.same_mobile_and_fixed_line_pattern) do
      @same_mobile_and_fixed_line_pattern_default
    else
      phone_metadata.same_mobile_and_fixed_line_pattern
    end
  end

  @main_country_for_code_default false
  def get_main_country_for_code_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.main_country_for_code) do
      @main_country_for_code_default
    else
      phone_metadata.main_country_for_code
    end
  end

  @mobile_number_portable_region_default false
  def get_mobile_number_portable_region_or_default(phone_metadata = %PhoneMetadata{}) do
    if is_nil(phone_metadata.mobile_number_portable_region) do
      @mobile_number_portable_region_default
    else
      phone_metadata.mobile_number_portable_region
    end
  end

  def has_leading_digits(%PhoneMetadata{} = phone_metadata) do
    not is_nil_or_empty?(phone_metadata.leading_digits)
  end

  def has_national_prefix?(%PhoneMetadata{} = phone_metadata) do
    not is_nil_or_empty?(phone_metadata.national_prefix)
  end

  def has_national_prefix_for_parsing?(%PhoneMetadata{} = phone_metadata) do
    not is_nil_or_empty?(phone_metadata.national_prefix_for_parsing)
  end

  def has_national_prefix_optional_when_formatting?(%PhoneMetadata{} = phone_metadata) do
    not is_nil_or_empty?(phone_metadata.national_prefix_optional_when_formatting)
  end

  def has_preferred_extn_prefix?(%PhoneMetadata{} = phone_metadata) do
    not is_nil_or_empty?(phone_metadata.preferred_extn_prefix)
  end

  def put_default_values(phone_metadata = %PhoneMetadata{}) do
    Logger.debug("----- Territory -----")
    Logger.debug("#{inspect(phone_metadata)}")
    Logger.debug("region_code: #{inspect(phone_metadata.id)}")

    phone_metadata =
      if has_national_prefix?(phone_metadata) do
        Logger.debug("has national_prefix")

        if not has_national_prefix_for_parsing?(phone_metadata) do
          Logger.debug("has not national_prefix_for_parsing")
          Logger.debug("national_prefix_for_parsing: #{inspect(phone_metadata.national_prefix)}")
          %{phone_metadata | national_prefix_for_parsing: phone_metadata.national_prefix}
        else
          phone_metadata
        end
      else
        Logger.debug("has not national_prefix")
        phone_metadata
      end

    phone_metadata = %{
      phone_metadata
      | national_prefix_formatting_rule: get_national_prefix_formatting_rule(phone_metadata)
    }

    Logger.debug("national_prefix_formatting_rule: #{inspect(phone_metadata.national_prefix_formatting_rule)}")

    phone_metadata = %{
      phone_metadata
      | carrier_code_formatting_rule: get_domestic_carrier_code_formatting_rule(phone_metadata)
    }

    Logger.debug("carrier_code_formatting_rule: #{inspect(phone_metadata.carrier_code_formatting_rule)}")

    Logger.debug("available_formats count: #{inspect(length(phone_metadata.available_formats))}")
    formats = get_number_format(phone_metadata)

    number_format =
      List.foldl(formats, [], fn x, acc ->
        ele = destructure_to_number_format(x)
        if is_nil(ele), do: acc, else: acc ++ [ele]
      end)

    Logger.debug("number_format count: #{inspect(length(number_format))}")

    intl_number_format =
      List.foldl(formats, [], fn x, acc ->
        ele = destructure_to_intl_number_format(x)
        if is_nil(ele), do: acc, else: acc ++ [ele]
      end)

    Logger.debug("intl_number_format count: #{inspect(length(intl_number_format))}")

    phone_metadata = %{
      phone_metadata
      | number_format: number_format,
        intl_number_format: intl_number_format
    }

    phone_metadata = %{
      phone_metadata
      | general: process_phone_number_description(phone_metadata.general, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | fixed_line: process_phone_number_description(phone_metadata.fixed_line, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | mobile: process_phone_number_description(phone_metadata.mobile, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | toll_free: process_other_phone_number_description(phone_metadata.toll_free, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | premium_rate: process_other_phone_number_description(phone_metadata.premium_rate, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | shared_cost: process_other_phone_number_description(phone_metadata.shared_cost, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | voip: process_other_phone_number_description(phone_metadata.voip, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | personal_number: process_other_phone_number_description(phone_metadata.personal_number, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | pager: process_other_phone_number_description(phone_metadata.pager, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | uan: process_other_phone_number_description(phone_metadata.uan, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | voicemail: process_other_phone_number_description(phone_metadata.voicemail, phone_metadata)
    }

    phone_metadata = %{
      phone_metadata
      | no_international_dialing:
          process_other_phone_number_description(
            phone_metadata.no_international_dialing,
            phone_metadata
          )
    }

    phone_metadata = %{
      phone_metadata
      | same_mobile_and_fixed_line_pattern:
          phone_metadata.mobile.national_number_pattern ==
            phone_metadata.fixed_line.national_number_pattern
    }

    {get_map_key(phone_metadata), phone_metadata}
  end

  def get_national_prefix_formatting_rule(%PhoneMetadata{
        national_prefix: prefix,
        national_prefix_formatting_rule: rule
      }),
      do: get_national_prefix_formatting_rule(prefix, rule)

  def get_national_prefix_formatting_rule(
        %NumberFormat{national_prefix_formatting_rule: rule},
        prefix
      ),
      do: get_national_prefix_formatting_rule(prefix, rule)

  def get_national_prefix_formatting_rule(prefix, rule) do
    rule = Regex.replace(~r/\$NP/, rule, prefix, global: false)
    Regex.replace(~r/\$FG/, rule, "\\\\g{1}", global: false)
  end

  def get_domestic_carrier_code_formatting_rule(%PhoneMetadata{
        national_prefix: prefix,
        carrier_code_formatting_rule: rule
      }),
      do: get_domestic_carrier_code_formatting_rule(prefix, rule)

  def get_domestic_carrier_code_formatting_rule(
        %NumberFormat{domestic_carrier_code_formatting_rule: rule},
        prefix
      ),
      do: get_domestic_carrier_code_formatting_rule(prefix, rule)

  def get_domestic_carrier_code_formatting_rule(prefix, rule) do
    rule = Regex.replace(~r/\$FG/, rule, "\\\\g{1}", global: false)
    Regex.replace(~r/\$NP/, rule, prefix, global: false)
  end

  def get_number_format(%PhoneMetadata{} = phone_metadata),
    do: get_number_format(phone_metadata.available_formats, phone_metadata)

  def get_number_format([head | tail], %PhoneMetadata{} = phone_metadata) do
    [get_number_format(head, phone_metadata) | get_number_format(tail, phone_metadata)]
  end

  def get_number_format(%{number_format: number_format}, %PhoneMetadata{} = phone_metadata) do
    Logger.debug("---> number_format")
    Logger.debug("\t#{inspect(number_format)}")

    number_format =
      Map.merge(
        number_format,
        if not is_nil_or_empty?(number_format.national_prefix_formatting_rule) do
          %{
            national_prefix_formatting_rule: get_national_prefix_formatting_rule(number_format, phone_metadata.national_prefix)
          }
        else
          %{national_prefix_formatting_rule: phone_metadata.national_prefix_formatting_rule}
        end
      )

    Logger.debug("\tnational_prefix_formatting_rule: #{inspect(number_format.national_prefix_formatting_rule)}")

    number_format =
      Map.merge(
        number_format,
        if is_nil_or_empty?(number_format.national_prefix_optional_when_formatting) do
          %{
            national_prefix_optional_when_formatting: has_national_prefix_optional_when_formatting?(phone_metadata)
          }
        else
          %{}
        end
      )

    Logger.debug(~s"\tnational_prefix_optional_when_formatting: #{inspect(number_format.national_prefix_optional_when_formatting)}")

    number_format =
      Map.merge(
        number_format,
        if not is_nil_or_empty?(number_format.domestic_carrier_code_formatting_rule) do
          %{
            domestic_carrier_code_formatting_rule:
              get_domestic_carrier_code_formatting_rule(
                number_format,
                phone_metadata.national_prefix
              )
          }
        else
          %{domestic_carrier_code_formatting_rule: phone_metadata.carrier_code_formatting_rule}
        end
      )

    Logger.debug(~s"\tdomestic_carrier_code_formatting_rule: #{inspect(number_format.domestic_carrier_code_formatting_rule)}")

    number_format =
      Map.merge(
        number_format,
        %{
          leading_digits_pattern:
            List.wrap(
              Enum.reduce(number_format.leading_digits_pattern, [], fn %{pattern: pattern}, _ ->
                pattern
              end)
            )
        }
      )

    Logger.debug(~s"\tleading_digits_pattern: #{inspect(number_format.leading_digits_pattern)}")

    intl_number_format = get_intl_format(number_format)
    Logger.debug("---> intl_number_format")
    Logger.debug("\t#{inspect(intl_number_format)}")
    %{number_format: number_format, intl_number_format: intl_number_format}
  end

  def get_number_format([], _), do: []

  def get_intl_format(%NumberFormat{} = number_format) do
    intl_number_format =
      if is_nil_or_empty?(number_format.intl_format) do
        Map.merge(%NumberFormat{}, number_format)
      else
        intl_number_format = %NumberFormat{
          pattern: number_format.pattern,
          leading_digits_pattern: number_format.leading_digits_pattern
        }

        if number_format.intl_format == Values.description_default_pattern() do
          intl_number_format
        else
          Map.merge(intl_number_format, %{format: number_format.intl_format})
        end
      end

    unless is_nil_or_empty?(intl_number_format.format) do
      intl_number_format
    else
      nil
    end
  end

  def destructure_to_number_format([]), do: []
  def destructure_to_number_format(%{number_format: number_format}), do: number_format
  def destructure_to_intl_number_format([]), do: []
  def destructure_to_intl_number_format(%{intl_number_format: number_format}), do: number_format

  def process_phone_number_description(nil, nil),
    do: process_phone_number_description(%PhoneNumberDescription{}, %PhoneNumberDescription{})

  def process_phone_number_description(nil, %PhoneMetadata{general: general}),
    do: process_phone_number_description(%PhoneNumberDescription{}, general)

  def process_phone_number_description(%PhoneNumberDescription{} = description, nil),
    do: process_phone_number_description(description, %PhoneNumberDescription{})

  def process_phone_number_description(%PhoneNumberDescription{} = description, %PhoneMetadata{
        general: general
      }),
      do: process_phone_number_description(description, general)

  def process_phone_number_description(
        %PhoneNumberDescription{} = description,
        %PhoneNumberDescription{} = general
      ) do
    national_number_pattern =
      if is_nil_or_empty?(description.national_number_pattern) do
        general.national_number_pattern
      else
        description.national_number_pattern
      end

    possible_lengths =
      if is_nil_or_empty?(description.possible_lengths) do
        general.possible_lengths
      else
        description.possible_lengths
      end

    example_number =
      if is_nil_or_empty?(description.example_number) do
        general.example_number
      else
        description.example_number
      end

    %PhoneNumberDescription{
      national_number_pattern: national_number_pattern,
      possible_lengths: possible_lengths,
      example_number: example_number
    }
  end

  def process_other_phone_number_description(description, %PhoneMetadata{general: general}) do
    if is_nil(description) do
      %PhoneNumberDescription{
        national_number_pattern: Values.description_default_pattern(),
        possible_lengths: Values.description_default_length()
      }
    else
      process_phone_number_description(description, general)
    end
  end
end

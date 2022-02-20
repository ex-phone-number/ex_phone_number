defmodule ExPhoneNumber.Model.PhoneNumber do
  @moduledoc """
  PhoneNumber module.
  """
  # number
  defstruct country_code: nil,
            # number
            national_number: nil,
            # string
            extension: nil,
            # boolean
            italian_leading_zero: nil,
            # number
            number_of_leading_zeros: nil,
            # string
            raw_input: nil,
            # atom
            country_code_source: nil,
            # string
            preferred_domestic_carrier_code: nil

  alias ExPhoneNumber.Model.PhoneNumber
  alias ExPhoneNumber.Constants.CountryCodeSource

  @spec clear_extension(%PhoneNumber{}) :: %PhoneNumber{}
  def clear_extension(phone_number = %PhoneNumber{}) do
    %PhoneNumber{phone_number | extension: nil}
  end

  @spec has_country_code?(%PhoneNumber{}) :: boolean()
  def has_country_code?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.country_code)
  end

  @national_number_default 0
  def get_national_number_or_default(phone_number = %PhoneNumber{}) do
    if is_nil(phone_number.national_number) do
      @national_number_default
    else
      phone_number.national_number
    end
  end

  @spec has_national_number?(%PhoneNumber{}) :: boolean()
  def has_national_number?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.national_number)
  end

  @spec has_extension?(%PhoneNumber{}) :: boolean()
  def has_extension?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.extension)
  end

  @spec has_italian_leading_zero?(%PhoneNumber{}) :: boolean()
  def has_italian_leading_zero?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.italian_leading_zero)
  end

  @number_of_leading_zeros_default 1
  def get_number_of_leading_zeros_or_default(phone_number = %PhoneNumber{}) do
    if is_nil(phone_number.number_of_leading_zeros) do
      @number_of_leading_zeros_default
    else
      phone_number.number_of_leading_zeros
    end
  end

  @spec has_number_of_leading_zeros?(%PhoneNumber{}) :: boolean()
  def has_number_of_leading_zeros?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.number_of_leading_zeros)
  end

  @spec has_raw_input?(%PhoneNumber{}) :: boolean()
  def has_raw_input?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.raw_input)
  end

  @country_code_default 1
  def get_country_code_or_default(phone_number = %PhoneNumber{}) do 
    if is_nil(phone_number.country_code) do
      @country_code_default
    else
      phone_number.country_code
    end
  end

  @country_code_source_default CountryCodeSource.from_number_with_plus_sign()
  def get_country_code_source_or_default(phone_number = %PhoneNumber{}) do
    if is_nil(phone_number.country_code_source) do
      @country_code_source_default
    else
      phone_number.country_code_source
    end
  end

  @spec has_country_code_source?(%PhoneNumber{}) :: boolean()
  def has_country_code_source?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.country_code_source)
  end

  @spec has_preferred_domestic_carrier_code?(%PhoneNumber{}) :: boolean()
  def has_preferred_domestic_carrier_code?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.preferred_domestic_carrier_code)
  end

  def get_national_significant_number(phone_number = %PhoneNumber{}) do
    national_number =
      if has_national_number?(phone_number) do
        phone_number.national_number
      else
        ""
      end

    if has_italian_leading_zero?(phone_number) and
         phone_number.italian_leading_zero and
         get_number_of_leading_zeros_or_default(phone_number) > 0 do
      upper_bound = get_number_of_leading_zeros_or_default(phone_number)
      prefix = for _x <- 1..upper_bound, do: "0"
      List.to_string(prefix) <> Integer.to_string(national_number)
    else
      case national_number do
        "" ->
          ""

        _ ->
          Integer.to_string(national_number)
      end
    end
  end

  def set_italian_leading_zeros(phone_number = %PhoneNumber{}, national_number) do
    if String.length(national_number) > 1 and String.at(national_number, 0) == "0" do
      phone_number = %{phone_number | italian_leading_zero: true}

      number_of_leading_zeros =
        Enum.reduce_while(String.graphemes(national_number), 0, fn ele, acc ->
          if ele == "0", do: {:cont, acc + 1}, else: {:halt, acc}
        end)

      number_of_leading_zeros =
        if String.ends_with?(national_number, "0"),
          do: number_of_leading_zeros - 1,
          else: number_of_leading_zeros

      if number_of_leading_zeros > 1,
        do: %{phone_number | number_of_leading_zeros: number_of_leading_zeros},
        else: phone_number
    else
      phone_number
    end
  end
end

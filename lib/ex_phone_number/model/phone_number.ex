defmodule ExPhoneNumber.Model.PhoneNumber do
  @moduledoc false

   @type t :: %__MODULE__{}

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

  alias ExPhoneNumber.Constants.CountryCodeSource
  alias ExPhoneNumber.Model.PhoneNumber

  def has_country_code?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.country_code)
  end

  def has_national_number?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.national_number)
  end

  def has_extension?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.extension)
  end

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

  def has_number_of_leading_zeros?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.number_of_leading_zeros)
  end

  def has_raw_input?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.raw_input)
  end

  @country_code_source_default CountryCodeSource.from_number_with_plus_sign()
  def get_country_code_source_or_default(phone_number = %PhoneNumber{}) do
    if is_nil(phone_number.country_code_source) do
      @country_code_source_default
    else
      phone_number.country_code_source
    end
  end

  def has_country_code_source?(phone_number = %PhoneNumber{}) do
    not is_nil(phone_number.country_code_source)
  end

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

    if has_italian_leading_zero?(phone_number) and phone_number.italian_leading_zero do
      upper_bound = get_number_of_leading_zeros_or_default(phone_number)
      prefix = for _x <- 1..upper_bound, do: "0"
      List.to_string(prefix) <> Integer.to_string(national_number)
    else
      Integer.to_string(national_number)
    end
  end

  def set_italian_leading_zeros(national_number, %PhoneNumber{} = phone_number) do
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

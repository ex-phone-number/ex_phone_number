# ExPhoneNumber

[![Build Status](https://travis-ci.org/socialpaymentsbv/ex_phone_number.svg?branch=develop)](https://travis-ci.org/socialpaymentsbv/ex_phone_number)
[![Module Version](https://img.shields.io/hexpm/v/ex_phone_number.svg)](https://hex.pm/packages/ex_phone_number)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_phone_number/)
[![Total Download](https://img.shields.io/hexpm/dt/ex_phone_number.svg)](https://hex.pm/packages/ex_phone_number)
[![License](https://img.shields.io/hexpm/l/ex_phone_number.svg)](https://github.com/socialpaymentsbv/ex_phone_number/blob/develop/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/socialpaymentsbv/ex_phone_number.svg)](https://github.com/socialpaymentsbv/ex_phone_number/commits/develop)

Elixir library for parsing, formatting, and validating international phone numbers.
Based on Google's [libphonenumber](https://github.com/googlei18n/libphonenumber) (current metadata version: 8.10.2).

## Installation

Add `:ex_phone_number` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_phone_number, "~> 0.2"}
  ]
end
```

## Usage

```elixir
iex> {:ok, phone_number} = ExPhoneNumber.parse("044 668 18 00", "CH")
{:ok,
 %ExPhoneNumber.Model.PhoneNumber{
   country_code: 41,
   country_code_source: nil,
   extension: nil,
   italian_leading_zero: nil,
   national_number: 446681800,
   number_of_leading_zeros: nil,
   preferred_domestic_carrier_code: nil,
   raw_input: nil
}}

iex> ExPhoneNumber.is_possible_number?(phone_number)
true

iex> ExPhoneNumber.is_valid_number?(phone_number)
true

iex> ExPhoneNumber.get_number_type(phone_number)
:fixed_line

iex> ExPhoneNumber.format(phone_number, :national)
"044 668 18 00"

iex> ExPhoneNumber.format(phone_number, :international)
"+41 44 668 18 00"

iex> ExPhoneNumber.format(phone_number, :e164)
"+41446681800"

iex> ExPhoneNumber.format(phone_number, :rfc3966)
"tel:+41-44-668-18-00"
```

##  E164 Formatted Numbers

In E164 formatted numbers the country code can be detected. So you can pass them in to `ExPhoneNumber.parse/2` with `""` or `nil` as the second argument.

```elixir
iex> ExPhoneNumber.parse("+977123456789", "")
{:ok,
 %ExPhoneNumber.Model.PhoneNumber{
   country_code: 977,
   country_code_source: nil,
   extension: nil,
   italian_leading_zero: nil,
   national_number: 123456789,
   number_of_leading_zeros: nil,
   preferred_domestic_carrier_code: nil,
   raw_input: nil
 }}
```

## Copyright and License

Copyright (c) 2016-2021 NLCollect B.V.

The source code is licensed under [The MIT License (MIT)](LICENSE.md)

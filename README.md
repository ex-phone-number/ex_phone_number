# ExPhoneNumber

[![Build Status](https://travis-ci.org/socialpaymentsbv/ex_phone_number.svg?branch=develop)](https://travis-ci.org/socialpaymentsbv/ex_phone_number)

It's a library for parsing, formatting, and validating international phone numbers.
Based on Google's [libphonenumber](https://github.com/googlei18n/libphonenumber).

## Installation

  1. Add `:ex_phone_number` to your list of dependencies in `mix.exs`:
```ex
def deps do
  [{:ex_phone_number, "~> 0.1"}]
end
```

  2. Add `:ex_phone_number` to the list of applications in `mix.exs`:
```ex
def application do
  [mod: {MyApp, []},
   applications: [..., :ex_phone_number]]
end
```

## Usage
```ex
iex> {result, phone_number} = ExPhoneNumber.parse("044 668 18 00", "CH")
#> {:ok, %ExPhoneNumber.Model.PhoneNumber{country_code: 41, country_code_source: nil, extension: nil,
#        italian_leading_zero: nil, national_number: 446681800, number_of_leading_zeros: nil,
#        preferred_domestic_carrier_code: nil, raw_input: nil}}

iex> ExPhoneNumber.is_possible_number?(phone_number)
#> true

iex> ExPhoneNumber.is_valid_number?(phone_number)
#> true

iex> ExPhoneNumber.get_number_type(phone_number)
#> :fixed_line

iex> ExPhoneNumber.format(phone_number, :national)
#> "044 668 18 00"

iex> ExPhoneNumber.format(phone_number, :international)
#> "+41 44 668 18 00"

iex> ExPhoneNumber.format(phone_number, :e164)
#> "+41446681800"

iex> ExPhoneNumber.format(phone_number, :rfc3966)
#> "tel:+41-44-668-18-00"
```

## License

The MIT License (MIT)
Copyright (c) 2016 NLCollect B.V.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

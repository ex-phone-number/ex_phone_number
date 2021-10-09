defmodule ExPhoneNumber.PhoneNumberFixture do
  @moduledoc """
  `%ExPhoneNumber.PhoneNumber{}` fixtures
  """

  alias ExPhoneNumber.Model.PhoneNumber

  def alpha_numeric_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 80_074_935_247
    }
  end

  def alpha_numeric_number2() do
    %PhoneNumber{
      country_code: 1,
      national_number: 80_074_935_247,
      extension: "1234"
    }
  end

  def ad_number() do
    %PhoneNumber{
      country_code: 376,
      national_number: 12_345
    }
  end

  def ae_uan() do
    %PhoneNumber{
      country_code: 971,
      national_number: 600_123_456
    }
  end

  def ar_mobile() do
    %PhoneNumber{
      country_code: 54,
      national_number: 91_187_654_321
    }
  end

  def ar_mobile2() do
    %PhoneNumber{
      country_code: 54,
      national_number: 93_435_551_212
    }
  end

  def ar_mobile3() do
    %PhoneNumber{
      country_code: 54,
      national_number: 93_715_654_320
    }
  end

  def ar_mobile4() do
    %PhoneNumber{
      country_code: 54,
      national_number: 92_234_654_321
    }
  end

  def ar_number() do
    %PhoneNumber{
      country_code: 54,
      national_number: 1_187_654_321
    }
  end

  def ar_number2() do
    %PhoneNumber{
      country_code: 54,
      national_number: 1_987_654_321
    }
  end

  def ar_number3() do
    %PhoneNumber{
      country_code: 54,
      national_number: 3_715_654_321
    }
  end

  def ar_number4() do
    %PhoneNumber{
      country_code: 54,
      national_number: 2_312_340_000
    }
  end

  def ar_number5() do
    %PhoneNumber{
      country_code: 54,
      national_number: 81_429_712
    }
  end

  def ar_number6() do
    %PhoneNumber{
      country_code: 54,
      national_number: 91_234_125_678,
      preferred_domestic_carrier_code: 19
    }
  end

  def au_number() do
    %PhoneNumber{
      country_code: 61,
      national_number: 236_618_300
    }
  end

  def au_number2() do
    %PhoneNumber{
      country_code: 61,
      national_number: 1_800_123_456
    }
  end

  def bs_mobile() do
    %PhoneNumber{
      country_code: 1,
      national_number: 2_423_570_000
    }
  end

  def bs_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 2_423_651_234
    }
  end

  def bs_number_invalid() do
    %PhoneNumber{
      country_code: 1,
      national_number: 2_421_232_345
    }
  end

  def by_number() do
    %PhoneNumber{
      country_code: 375,
      national_number: 8123
    }
  end

  def by_number2() do
    %PhoneNumber{
      country_code: 375,
      national_number: 81234
    }
  end

  def by_number3() do
    %PhoneNumber{
      country_code: 375,
      national_number: 812_345
    }
  end

  def by_number4() do
    %PhoneNumber{
      country_code: 375,
      national_number: 123_456
    }
  end

  def de_number() do
    %PhoneNumber{
      country_code: 49,
      national_number: 30_123_456
    }
  end

  def de_number2() do
    %PhoneNumber{
      country_code: 49,
      national_number: 301_234
    }
  end

  def de_number3() do
    %PhoneNumber{
      country_code: 49,
      national_number: 291_123
    }
  end

  def de_number4() do
    %PhoneNumber{
      country_code: 49,
      national_number: 29_112_345_678
    }
  end

  def de_number5() do
    %PhoneNumber{
      country_code: 49,
      national_number: 912_312_345
    }
  end

  def de_number6() do
    %PhoneNumber{
      country_code: 49,
      national_number: 80_212_345
    }
  end

  def de_number7() do
    %PhoneNumber{
      country_code: 49,
      national_number: 41_341_234
    }
  end

  def de_short_number() do
    %PhoneNumber{
      country_code: 49,
      national_number: 1234
    }
  end

  def de_premium() do
    %PhoneNumber{
      country_code: 49,
      national_number: 9_001_654_321
    }
  end

  def de_premium2() do
    %PhoneNumber{
      country_code: 49,
      national_number: 90_091_234_567
    }
  end

  def de_toll_free() do
    %PhoneNumber{
      country_code: 49,
      national_number: 8_001_234_567
    }
  end

  def de_mobile() do
    %PhoneNumber{
      country_code: 49,
      national_number: 15_123_456_789
    }
  end

  def de_invalid() do
    %PhoneNumber{
      country_code: 49,
      national_number: 1234
    }
  end

  def empty_number() do
    %PhoneNumber{}
  end

  def gb_mobile() do
    %PhoneNumber{
      country_code: 44,
      national_number: 7_912_345_678
    }
  end

  def gb_number() do
    %PhoneNumber{
      country_code: 44,
      national_number: 2_070_313_000
    }
  end

  def gb_premium() do
    %PhoneNumber{
      country_code: 44,
      national_number: 9_187_654_321
    }
  end

  def gb_toll_free() do
    %PhoneNumber{
      country_code: 44,
      national_number: 8_012_345_678
    }
  end

  def gb_toll_free_too_long() do
    %PhoneNumber{
      country_code: 44,
      national_number: 80_123_456_780_123
    }
  end

  def gb_shared_cost() do
    %PhoneNumber{
      country_code: 44,
      national_number: 8_431_231_234
    }
  end

  def gb_voip() do
    %PhoneNumber{
      country_code: 44,
      national_number: 5_631_231_234
    }
  end

  def gb_personal_number() do
    %PhoneNumber{
      country_code: 44,
      national_number: 7_031_231_234
    }
  end

  def gb_invalid() do
    %PhoneNumber{
      country_code: 44,
      national_number: 791_234_567
    }
  end

  def gb_short_number() do
    %PhoneNumber{
      country_code: 44,
      national_number: 300
    }
  end

  def gb_short_number_with_leading_zero() do
    %PhoneNumber{
      country_code: 44,
      national_number: 123_456,
      italian_leading_zero: true
    }
  end

  def gb_number2() do
    %PhoneNumber{
      country_code: 44,
      national_number: 2_034_567_890,
      extension: "456"
    }
  end

  def it_mobile() do
    %PhoneNumber{
      country_code: 39,
      national_number: 345_678_901
    }
  end

  def it_number() do
    %PhoneNumber{
      country_code: 39,
      national_number: 236_618_300,
      italian_leading_zero: true
    }
  end

  def it_number2() do
    %PhoneNumber{
      country_code: 39,
      national_number: 2_234_567_890,
      italian_leading_zero: true
    }
  end

  def it_number2_too_long() do
    %PhoneNumber{
      country_code: 39,
      national_number: 2_234_567_890_123,
      italian_leading_zero: true
    }
  end

  def it_premium() do
    %PhoneNumber{
      country_code: 39,
      national_number: 892_123
    }
  end

  def it_toll_free() do
    %PhoneNumber{
      country_code: 39,
      national_number: 803_123
    }
  end

  def it_invalid() do
    %PhoneNumber{
      country_code: 39,
      national_number: 23_661_830_000,
      italian_leading_zero: true
    }
  end

  def au_leading_zero() do
    %PhoneNumber{
      country_code: 61,
      national_number: 11,
      italian_leading_zero: true
    }
  end

  def au_leading_zero2() do
    %PhoneNumber{
      country_code: 61,
      national_number: 1,
      italian_leading_zero: true,
      number_of_leading_zeros: 2
    }
  end

  def au_leading_zero3() do
    %PhoneNumber{
      country_code: 61,
      national_number: 0,
      italian_leading_zero: true,
      number_of_leading_zeros: 2
    }
  end

  def au_leading_zero4() do
    %PhoneNumber{
      country_code: 61,
      national_number: 0,
      italian_leading_zero: true,
      number_of_leading_zeros: 3
    }
  end

  def jp_star_number() do
    %PhoneNumber{
      country_code: 81,
      national_number: 2345
    }
  end

  def mx_mobile1() do
    %PhoneNumber{
      country_code: 52,
      national_number: 12_345_678_900
    }
  end

  def mx_mobile2() do
    %PhoneNumber{
      country_code: 52,
      national_number: 15_512_345_678
    }
  end

  def mx_number1() do
    %PhoneNumber{
      country_code: 52,
      national_number: 3_312_345_678
    }
  end

  def mx_number2() do
    %PhoneNumber{
      country_code: 52,
      national_number: 8_211_234_567
    }
  end

  def mx_number3() do
    %PhoneNumber{
      country_code: 52,
      national_number: 4_499_780_001
    }
  end

  def mx_number4() do
    %PhoneNumber{
      country_code: 52,
      national_number: 13_312_345_678
    }
  end

  def nz_number() do
    %PhoneNumber{
      country_code: 64,
      national_number: 33_316_005
    }
  end

  def nz_number2() do
    %PhoneNumber{
      country_code: 64,
      national_number: 21_387_835
    }
  end

  def nz_number3() do
    %PhoneNumber{
      country_code: 64,
      national_number: 64_123_456
    }
  end

  def nz_invalid() do
    %PhoneNumber{
      country_code: 64,
      national_number: 3_316_005
    }
  end

  def nz_short_number() do
    %PhoneNumber{
      country_code: 64,
      national_number: 12
    }
  end

  def nz_toll_free() do
    %PhoneNumber{
      country_code: 64,
      national_number: 800_332_005
    }
  end

  def nz_premium() do
    %PhoneNumber{
      country_code: 64,
      national_number: 9_003_326_005
    }
  end

  def nz_number4() do
    %PhoneNumber{
      country_code: 64,
      national_number: 33_316_005,
      extension: "3456"
    }
  end

  def re_number() do
    %PhoneNumber{
      country_code: 262,
      national_number: 262_123_456
    }
  end

  def re_number_invalid() do
    %PhoneNumber{
      country_code: 262,
      national_number: 269_123_456
    }
  end

  def re_yt_number() do
    %PhoneNumber{
      country_code: 262,
      national_number: 800_123_456
    }
  end

  def sg_number() do
    %PhoneNumber{
      country_code: 65,
      national_number: 65_218_000
    }
  end

  def sg_number2() do
    %PhoneNumber{
      country_code: 65,
      national_number: 1_234_567_890
    }
  end

  def us_long_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 65_025_300_001
    }
  end

  def us_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 6_502_530_000
    }
  end

  def us_number2() do
    %PhoneNumber{
      country_code: 1,
      national_number: 1_234_567_890
    }
  end

  def us_number3() do
    %PhoneNumber{
      country_code: 1,
      national_number: 4_241_231_234,
      preferred_domestic_carrier_code: 99
    }
  end

  def us_premium() do
    %PhoneNumber{
      country_code: 1,
      national_number: 9_002_530_000
    }
  end

  def us_local_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 2_530_000
    }
  end

  def us_short_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 1_234
    }
  end

  def us_short_by_one_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 650_253_000
    }
  end

  def us_tollfree() do
    %PhoneNumber{
      country_code: 1,
      national_number: 8_002_530_000
    }
  end

  def us_tollfree2() do
    %PhoneNumber{
      country_code: 1,
      national_number: 8_881_234_567
    }
  end

  def us_spoof() do
    %PhoneNumber{
      country_code: 1,
      national_number: 0
    }
  end

  def us_spoof_with_raw_input() do
    %PhoneNumber{
      country_code: 1,
      national_number: 0,
      raw_input: "000-000-0000"
    }
  end

  def us_number_with_extension() do
    %PhoneNumber{
      country_code: 1,
      national_number: 8_009_013_355,
      extension: "7246433"
    }
  end

  def us_number_with_extension2() do
    %PhoneNumber{
      country_code: 1,
      national_number: 2_121_231_234,
      extension: "508"
    }
  end

  def us_number_with_extension3() do
    %PhoneNumber{
      country_code: 1,
      national_number: 6_451_231_234,
      extension: "910"
    }
  end

  def us_invalid_prefix() do
    %PhoneNumber{
      country_code: 1,
      national_number: 2_401_234_567
    }
  end

  def uz_fixed_line() do
    %PhoneNumber{
      country_code: 998,
      national_number: 612_201_234
    }
  end

  def uz_mobile() do
    %PhoneNumber{
      country_code: 998,
      national_number: 950_123_456
    }
  end

  def yt_number() do
    %PhoneNumber{
      country_code: 262,
      national_number: 269_601_234
    }
  end

  def international_toll_free() do
    %PhoneNumber{
      country_code: 800,
      national_number: 12_345_678
    }
  end

  def international_toll_free_too_long() do
    %PhoneNumber{
      country_code: 800,
      national_number: 123_456_789
    }
  end

  def universal_premium_rate() do
    %PhoneNumber{
      country_code: 979,
      national_number: 123_456_789
    }
  end

  def nanpa_short_number() do
    %PhoneNumber{
      country_code: 1,
      national_number: 253_000
    }
  end

  def unknown_country_code() do
    %PhoneNumber{
      country_code: 3923,
      national_number: 2366
    }
  end

  def unknown_country_code2() do
    %PhoneNumber{
      country_code: 0,
      national_number: 2366
    }
  end

  def unknown_country_code3() do
    %PhoneNumber{
      country_code: 0,
      national_number: 2_530_000
    }
  end

  def unknown_country_code_no_raw_input() do
    %PhoneNumber{
      country_code: 2,
      national_number: 12_345
    }
  end

  def too_many_zeros1() do
    %PhoneNumber{
      country_code: 1,
      national_number: 650,
      italian_leading_zero: true,
      number_of_leading_zeros: 2
    }
  end

  def too_many_zeros2() do
    %PhoneNumber{
      country_code: 1,
      national_number: 650,
      italian_leading_zero: true,
      number_of_leading_zeros: -3
    }
  end

  def invalid_country_calling_code() do
    %PhoneNumber{
      country_code: 123,
      national_number: 6_502_530_000
    }
  end
end

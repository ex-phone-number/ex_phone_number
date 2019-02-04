defmodule ExPhoneNumber.Constants.Mappings do
  alias ExPhoneNumber.Constants.Values

  def digit_mappings() do
    %{
      "0" => "0",
      "1" => "1",
      "2" => "2",
      "3" => "3",
      "4" => "4",
      "5" => "5",
      "6" => "6",
      "7" => "7",
      "8" => "8",
      "9" => "9",
      # Fullwidth digit 0
      "\uFF10" => "0",
      # Fullwidth digit 1
      "\uFF11" => "1",
      # Fullwidth digit 2
      "\uFF12" => "2",
      # Fullwidth digit 3
      "\uFF13" => "3",
      # Fullwidth digit 4
      "\uFF14" => "4",
      # Fullwidth digit 5
      "\uFF15" => "5",
      # Fullwidth digit 6
      "\uFF16" => "6",
      # Fullwidth digit 7
      "\uFF17" => "7",
      # Fullwidth digit 8
      "\uFF18" => "8",
      # Fullwidth digit 9
      "\uFF19" => "9",
      # Arabic-indic digit 0
      "\u0660" => "0",
      # Arabic-indic digit 1
      "\u0661" => "1",
      # Arabic-indic digit 2
      "\u0662" => "2",
      # Arabic-indic digit 3
      "\u0663" => "3",
      # Arabic-indic digit 4
      "\u0664" => "4",
      # Arabic-indic digit 5
      "\u0665" => "5",
      # Arabic-indic digit 6
      "\u0666" => "6",
      # Arabic-indic digit 7
      "\u0667" => "7",
      # Arabic-indic digit 8
      "\u0668" => "8",
      # Arabic-indic digit 9
      "\u0669" => "9",
      # Eastern-Arabic digit 0
      "\u06F0" => "0",
      # Eastern-Arabic digit 1
      "\u06F1" => "1",
      # Eastern-Arabic digit 2
      "\u06F2" => "2",
      # Eastern-Arabic digit 3
      "\u06F3" => "3",
      # Eastern-Arabic digit 4
      "\u06F4" => "4",
      # Eastern-Arabic digit 5
      "\u06F5" => "5",
      # Eastern-Arabic digit 6
      "\u06F6" => "6",
      # Eastern-Arabic digit 7
      "\u06F7" => "7",
      # Eastern-Arabic digit 8
      "\u06F8" => "8",
      # Eastern-Arabic digit 9
      "\u06F9" => "9"
    }
  end

  def diallable_char_mappings() do
    %{
      "0" => "0",
      "1" => "1",
      "2" => "2",
      "3" => "3",
      "4" => "4",
      "5" => "5",
      "6" => "6",
      "7" => "7",
      "8" => "8",
      "9" => "9",
      "+" => Values.plus_sign(),
      "*" => "*"
    }
  end

  def alpha_mappings() do
    %{
      "A" => "2",
      "B" => "2",
      "C" => "2",
      "D" => "3",
      "E" => "3",
      "F" => "3",
      "G" => "4",
      "H" => "4",
      "I" => "4",
      "J" => "5",
      "K" => "5",
      "L" => "5",
      "M" => "6",
      "N" => "6",
      "O" => "6",
      "P" => "7",
      "Q" => "7",
      "R" => "7",
      "S" => "7",
      "T" => "8",
      "U" => "8",
      "V" => "8",
      "W" => "9",
      "X" => "9",
      "Y" => "9",
      "Z" => "9"
    }
  end

  def all_normalization_mappings() do
    %{
      "0" => "0",
      "1" => "1",
      "2" => "2",
      "3" => "3",
      "4" => "4",
      "5" => "5",
      "6" => "6",
      "7" => "7",
      "8" => "8",
      "9" => "9",
      # Fullwidth digit 0
      "\uFF10" => "0",
      # Fullwidth digit 1
      "\uFF11" => "1",
      # Fullwidth digit 2
      "\uFF12" => "2",
      # Fullwidth digit 3
      "\uFF13" => "3",
      # Fullwidth digit 4
      "\uFF14" => "4",
      # Fullwidth digit 5
      "\uFF15" => "5",
      # Fullwidth digit 6
      "\uFF16" => "6",
      # Fullwidth digit 7
      "\uFF17" => "7",
      # Fullwidth digit 8
      "\uFF18" => "8",
      # Fullwidth digit 9
      "\uFF19" => "9",
      # Arabic-indic digit 0
      "\u0660" => "0",
      # Arabic-indic digit 1
      "\u0661" => "1",
      # Arabic-indic digit 2
      "\u0662" => "2",
      # Arabic-indic digit 3
      "\u0663" => "3",
      # Arabic-indic digit 4
      "\u0664" => "4",
      # Arabic-indic digit 5
      "\u0665" => "5",
      # Arabic-indic digit 6
      "\u0666" => "6",
      # Arabic-indic digit 7
      "\u0667" => "7",
      # Arabic-indic digit 8
      "\u0668" => "8",
      # Arabic-indic digit 9
      "\u0669" => "9",
      # Eastern-Arabic digit 0
      "\u06F0" => "0",
      # Eastern-Arabic digit 1
      "\u06F1" => "1",
      # Eastern-Arabic digit 2
      "\u06F2" => "2",
      # Eastern-Arabic digit 3
      "\u06F3" => "3",
      # Eastern-Arabic digit 4
      "\u06F4" => "4",
      # Eastern-Arabic digit 5
      "\u06F5" => "5",
      # Eastern-Arabic digit 6
      "\u06F6" => "6",
      # Eastern-Arabic digit 7
      "\u06F7" => "7",
      # Eastern-Arabic digit 8
      "\u06F8" => "8",
      # Eastern-Arabic digit 9
      "\u06F9" => "9",
      "A" => "2",
      "B" => "2",
      "C" => "2",
      "D" => "3",
      "E" => "3",
      "F" => "3",
      "G" => "4",
      "H" => "4",
      "I" => "4",
      "J" => "5",
      "K" => "5",
      "L" => "5",
      "M" => "6",
      "N" => "6",
      "O" => "6",
      "P" => "7",
      "Q" => "7",
      "R" => "7",
      "S" => "7",
      "T" => "8",
      "U" => "8",
      "V" => "8",
      "W" => "9",
      "X" => "9",
      "Y" => "9",
      "Z" => "9"
    }
  end

  def all_plus_number_grouping_symbols() do
    %{
      "0" => "0",
      "1" => "1",
      "2" => "2",
      "3" => "3",
      "4" => "4",
      "5" => "5",
      "6" => "6",
      "7" => "7",
      "8" => "8",
      "9" => "9",
      "A" => "A",
      "B" => "B",
      "C" => "C",
      "D" => "D",
      "E" => "E",
      "F" => "F",
      "G" => "G",
      "H" => "H",
      "I" => "I",
      "J" => "J",
      "K" => "K",
      "L" => "L",
      "M" => "M",
      "N" => "N",
      "O" => "O",
      "P" => "P",
      "Q" => "Q",
      "R" => "R",
      "S" => "S",
      "T" => "T",
      "U" => "U",
      "V" => "V",
      "W" => "W",
      "X" => "X",
      "Y" => "Y",
      "Z" => "Z",
      "a" => "A",
      "b" => "B",
      "c" => "C",
      "d" => "D",
      "e" => "E",
      "f" => "F",
      "g" => "G",
      "h" => "H",
      "i" => "I",
      "j" => "J",
      "k" => "K",
      "l" => "L",
      "m" => "M",
      "n" => "N",
      "o" => "O",
      "p" => "P",
      "q" => "Q",
      "r" => "R",
      "s" => "S",
      "t" => "T",
      "u" => "U",
      "v" => "V",
      "w" => "W",
      "x" => "X",
      "y" => "Y",
      "z" => "Z",
      "-" => "-",
      "\uFF0D" => "-",
      "\u2010" => "-",
      "\u2011" => "-",
      "\u2012" => "-",
      "\u2013" => "-",
      "\u2014" => "-",
      "\u2015" => "-",
      "\u2212" => "-",
      "/" => "/",
      "\uFF0F" => "/",
      " " => " ",
      "\u3000" => " ",
      "\u2060" => " ",
      "." => ".",
      "\uFF0E" => "."
    }
  end
end

defmodule ExPhoneNumber.Utilities do
  @moduledoc false

  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneNumberDescription

  def is_nil_or_empty?(nil), do: true
  def is_nil_or_empty?(string) when is_binary(string), do: String.length(string) == 0
  def is_nil_or_empty?(_), do: false

  def is_number_matching_description?(number, %PhoneNumberDescription{} = description)
      when is_binary(number) do
    if description.possible_lengths == Values.description_default_length() or
         description.national_number_pattern == Values.description_default_pattern() do
      false
    else
      matches_entirely?(description.national_number_pattern, number)
    end
  end

  def matches_entirely?(nil, _string), do: false

  def matches_entirely?(regex, string) when is_map(regex), do: matches_entirely?(regex.source, string)

  def matches_entirely?(regex, string) do
    regex = compile_regex!("^(?:" <> regex <> ")$")

    case Regex.run(regex, string, return: :index) do
      [{_index, length} | _tail] -> Kernel.byte_size(string) == length
      _ -> false
    end
  end

  @doc """
  `Regex.compile/2`, compiled once per `source` and `opts` and then reused.

  Since OTP 28 a compiled regex cannot be stored in a module attribute, so the metadata keeps its
  patterns as strings. Compiling them on every use made compilation most of the cost of parsing,
  formatting and validating a number. Every source comes from the metadata or the library's own
  constants, never from the number, so the set of cached patterns is bounded.
  """
  def compile_regex(source, opts \\ "") do
    key = {__MODULE__, :regex, source, opts}

    case :persistent_term.get(key, nil) do
      nil ->
        compiled = Regex.compile(source, opts)
        :persistent_term.put(key, compiled)
        compiled

      compiled ->
        compiled
    end
  end

  @doc "`compile_regex/2` that raises like `Regex.compile!/2` when `source` is invalid."
  def compile_regex!(source, opts \\ "") do
    case compile_regex(source, opts) do
      {:ok, regex} -> regex
      {:error, _reason} -> Regex.compile!(source, opts)
    end
  end
end
